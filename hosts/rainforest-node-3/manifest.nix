{
  flake.colmena.rainforest-node-3 = {
    imports = [
      ../../modules/roles/server

      ../../modules/roles/s3
    ];
  };
}
