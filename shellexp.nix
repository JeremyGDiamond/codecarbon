{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "codecarbon-dev";
  buildInputs = with pkgs; [
    python312
    python312Packages.pip
    python312Packages.setuptools
    python312Packages.wheel
    python312Packages.virtualenv
    gcc
    libffi
    openssl
    zlib
    stdenv.cc.cc.lib
    util-linux
    pciutils
    kmod
    bc
    linuxKernel.packages.linux_6_6.turbostat
  ];
  
  shellHook = ''
    echo "Entering CodeCarbon dev shell..."
    
    export LD_LIBRARY_PATH="${pkgs.zlib}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.libffi}/lib:${pkgs.openssl.out}/lib:$LD_LIBRARY_PATH"
    export PYTHONPATH=""
    export CODECARBON_CPU_POWER_METHOD=rapl
    
    # Check RAPL availability and permissions
    if [ -d "/sys/class/powercap/intel-rapl" ]; then
      echo "RAPL directory exists"
      if [ -r "/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj" ]; then
        echo "RAPL is readable - should work!"
      else
        echo "RAPL exists but not readable - you may need: sudo chmod -R +r /sys/class/powercap/intel-rapl/"
      fi
    else
      echo "RAPL not available"
    fi
    
    if [ ! -d .venv ]; then
      echo "Creating virtualenv..."
      python3 -m venv .venv
      source .venv/bin/activate
      pip install --upgrade pip
      pip install -r requirements.txt
    else
      source .venv/bin/activate
    fi
    echo "Virtualenv activated."
    sudo python -m codecarbon.cli.main monitor 0.001 &
    CCPID=$!
    pushd ../energy_exp_server
    sudo ./runCC.sh $BENCH $NAME
    popd
    kill $CCPID
    exit
  '';
}