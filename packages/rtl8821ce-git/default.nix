{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  bc,
  src,
  nix-update-script,
  ...
}:
stdenv.mkDerivation {
  pname = "rtl8821ce";
  version = "unstable-master-git";
  src = src;

  hardeningDisable = ["pic"];

  nativeBuildInputs = [bc] ++ kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags;

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace-fail /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace-fail /sbin/depmod \# \
      --replace-fail '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script {extraArgs = ["--version=branch=master"];};

  meta = {
    description = "Realtek rtl8821ce driver";
    homepage = "https://github.com/tomaspinho/rtl8821ce";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [defelo];
    broken =
      stdenv.hostPlatform.isAarch64
      || ((lib.versions.majorMinor kernel.version) == "5.4" && kernel.isHardened);
  };
}
