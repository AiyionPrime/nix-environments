{ pkgs ? import <nixpkgs> {}
, extraPkgs ? []
}:

let
  fixWrapper = pkgs.runCommand "fix-wrapper" {} ''
    mkdir -p $out/bin
    for i in ${pkgs.gcc.cc}/bin/*-gnu-gcc*; do
      ln -s ${pkgs.gcc}/bin/gcc $out/bin/$(basename "$i")
    done
    for i in ${pkgs.gcc.cc}/bin/*-gnu-{g++,c++}*; do
      ln -s ${pkgs.gcc}/bin/g++ $out/bin/$(basename "$i")
    done
    ln -sf ${pkgs.gcc.cc}/bin/{,*-gnu-}gcc-{ar,nm,ranlib} $out/bin
  '';

  fhs = pkgs.buildFHSEnv {
    name = "openwrt-env";
    targetPkgs = pkgs: with pkgs; [
      binutils
      file
      fixWrapper
      gcc
      git
      glibc.static
      gnumake
      ncurses
      openssl
      patch
      perl
      perlPackages.FileFinder
      pkg-config
      (python3.withPackages (ps: [ ps.setuptools ]))
      rsync
      subversion
      swig
      systemd
      unzip
      util-linux
      wget
      which
      zlib
      zlib.static
    ] ++ extraPkgs;
    multiPkgs = null;
    extraOutputsToInstall = [ "dev" ];
    profile = ''
      export hardeningDisable=all
    '';
  };
in fhs
