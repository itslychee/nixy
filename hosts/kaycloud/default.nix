{
  lib,
  ...
}:
{
  hey.hostKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAnZoLOT6p4Pkad9YGTiVQvYTWuT6nG1UN2TeMacMNoG";

  networking.networkmanager.enable = lib.mkForce false;

  services.consul.extraConfig.server = true;

}
