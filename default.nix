{ stdenv, fetchgit, ghc, perl, gmp, ncurses, happy, alex, autoconf, automake }:

stdenv.mkDerivation rec {
  version = "HEAD";
  name = "ghc-${version}";

  src = fetchgit {
    url = "https://git.haskell.org/ghc.git";
    rev = "refs/heads/master";
    sha256 = "0z6b19927kyxkfwic5k5ql6l3p2fsrfd7jk9h0c64wkyjj077jwi";
  };

  buildInputs = [ ghc perl gmp ncurses happy alex autoconf automake ];

  enableParallelBuilding = true;

  buildMK = ''
    libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-libraries="${gmp}/lib"
    libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-includes="${gmp}/include"
    DYNAMIC_BY_DEFAULT = NO
  '';

  preConfigure = ''
    ${perl}/bin/perl boot

    echo "${buildMK}" > mk/build.mk
    sed -i -e 's|-isysroot /Developer/SDKs/MacOSX10.5.sdk||' configure
  '' + stdenv.lib.optionalString (!stdenv.isDarwin) ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/ghc-${version}"
  '';

  configureFlags = "--with-gcc=${stdenv.gcc}/bin/gcc";

  # required, because otherwise all symbols from HSffi.o are stripped, and
  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" "--keep-file-symbols" ];

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = [
      stdenv.lib.maintainers.marcweber
      stdenv.lib.maintainers.andres
      stdenv.lib.maintainers.simons
    ];
  };

}
