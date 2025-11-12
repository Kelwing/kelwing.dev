# Kelwing Homepage

Uses a nix flake to host my homepage on NixOS using nginx.

## Usage

### In your NixOS configuration

Add this flake as an input to your system's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kelwing-homepage.url = "github:Kelwing/kelwing.dev";
  };

  outputs = { self, nixpkgs, kelwing-homepage }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        kelwing-homepage.nixosModules.default
        {
          # Your existing nginx configuration
          services.nginx.enable = true;

          # Add the static site as a virtualhost
          services.kelwing-homepage = {
            enable = true;
            virtualHost = "kelwing.dev";
            extraVirtualHostConfig = {
              listen = [ { addr = "0.0.0.0"; port = 80; } ];
              # Optional: Add SSL
              # enableACME = true;
              # forceSSL = true;
            };
          };
        }
      ];
    };
  };
}
```

### Testing locally

You can test the module using `nixos-rebuild`:

```bash
# Test the configuration
sudo nixos-rebuild test --flake .#yourhostname

# Apply permanently
sudo nixos-rebuild switch --flake .#yourhostname
```

## Module Options

- `services.kelwing-homepage.enable`: Enable the static site server (default: `false`)
- `services.kelwing-homepage.virtualHost`: Virtual host name for the site (default: `"localhost"`)
- `services.kelwing-homepage.extraVirtualHostConfig`: Extra nginx virtualhost configuration (default: `{}`)
  - You can specify `listen`, `enableACME`, `forceSSL`, and any other nginx virtualHost options here

## Example Configurations

### Simple local testing
```nix
services.kelwing-homepage = {
  enable = true;
  virtualHost = "localhost";
  extraVirtualHostConfig = {
    listen = [ { addr = "127.0.0.1"; port = 8080; } ];
  };
};
```

### Production with SSL
```nix
services.kelwing-homepage = {
  enable = true;
  virtualHost = "mysite.example.com";
  extraVirtualHostConfig = {
    enableACME = true;
    forceSSL = true;
  };
};
```

### Multiple ports
```nix
services.kelwing-homepage = {
  enable = true;
  virtualHost = "example.com";
  extraVirtualHostConfig = {
    listen = [
      { addr = "0.0.0.0"; port = 80; }
      { addr = "0.0.0.0"; port = 8080; }
    ];
  };
};
```

## File Structure

The module expects the following files in the repository root:
- `index.html` - Main HTML file
- `style.css` - Stylesheet

## Notes

- This module only adds a virtualhost configuration; it does not enable nginx itself
- You need to have `services.nginx.enable = true;` in your configuration
- Firewall configuration should be handled in your main nginx setup or separately
