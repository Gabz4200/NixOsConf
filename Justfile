# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Use zsh for recipes
set shell := ["zsh", "-c"]

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

# List all the just commands
default:
  @just --list

# Run eval tests
[group('nix')]
test:
  nix eval .#evalTests --show-trace --print-build-logs --verbose

# Update all the flake inputs
[group('nix')]
up:
  nix flake update --commit-lock-file

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}} --commit-lock-file

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

# remove all generations older than 7 days
# on darwin, you may need to switch to root user to run this command
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d
  nix profile wipe-history --profile "$XDG_STATE_HOME/nix/profiles/home-manager" --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  sudo nix-collect-garbage --delete-older-than 7d
  nix-collect-garbage --delete-older-than 7d

# Enter a shell session which has all the necessary tools for this flake
[linux]
[group('nix')]
shell:
  nix shell nixpkgs#git nixpkgs#neovim nixpkgs#alejandra nixpkgs#nixd nixpkgs#vscodium-fhs

[group('nix')]
fmt:
  alejandra .

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/

# Verify all the store entries
# Nix Store can contains corrupted entries if the nix store object has been modified unexpectedly.
# This command will verify all the store entries,
# and we need to fix the corrupted entries manually via `sudo nix store delete <store-path-1> <store-path-2> ...`
[group('nix')]
verify-store:
  nix store verify --all

# Repair Nix Store Objects
[group('nix')]
repair-store *paths:
  nix store repair {{paths}}

# Update all Nixpkgs inputs
[group('nix')]
up-nix:
  nix flake update nixpkgs nixpkgs-stable nixpkgs-unstable nixpkgs-darwin nixpkgs-ollama

############################################################################
#
#  NixOS Desktop related commands
#
############################################################################

# Deploy configuration
# Usage: just switch "message"
[group('nixos')]
switch message:
  git add .
  git commit -m {{message}}
  nix flake update --commit-lock-file
  sudo nixos-rebuild switch --flake .

# Gen new facter.json
# Usage: just fac
[group('nixos')]
fac message:
  sudo rm ./facter.json
  sudo nix run --option experimental-features "nix-command flakes" --option extra-substituters https://numtide.cachix.org --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= github:nix-community/nixos-facter -- -o facter.json
  git add .
  git commit --amend -a --no-edit

# Deploy configuration without updating
# Usage: just ss "message"
[group('nixos')]
ss message:
  git add .
  git commit -m {{message}}
  sudo nixos-rebuild switch --flake .

# Deploy configuration with boot
# Usage: just boot "message"
[group('nixos')]
boot message:
  git add .
  git commit -m {{message}}
  nix flake update --commit-lock-file
  sudo nixos-rebuild boot --flake .

# Deploy configuration with boot and no update
# Usage: just bb "message"
[group('nixos')]
bb message:
  git add .
  git commit -m {{message}}
  sudo nixos-rebuild boot --flake .

# Late Deploy configuration
# Usage: just ldp (switch/boot)
[group('nixos')]
ldp type:
  git add .
  git commit --amend -a --no-edit
  sudo nixos-rebuild {{type}} --flake .

# Late Deploy configuration
# Usage: just uldp (switch/boot)
[group('nixos')]
uldp type:
  git add .
  git commit --amend -a --no-edit
  nix flake update --commit-lock-file
  sudo nixos-rebuild {{type}} --flake .

# =================================================
#
# Other useful commands
#
# =================================================

[group('common')]
path:
  printf "%s\n" "$PATH" | tr ':' '\n'

[group('common')]
trace-access app *args:
  strace -f -t -e trace=file {{app}} {{args}} 2>&1 \
    | grep -oE '"(/[^\"]+)"' \
    | sed -E 's/"(\/[^\"]+)"/\1/' \
    | grep -vE '(/nix/store|/newroot|/proc)' \
    | sort -u

[linux]
[group('common')]
penvof pid:
  sudo tr '\0' '\n' < /proc/{{pid}}/environ

# Remove all reflog entries and prune unreachable objects
[group('git')]
ggc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

# Amend the last commit without changing the commit message
[group('git')]
game:
  git commit --amend -a --no-edit

[linux]
[group('services')]
list-inactive:
  systemctl list-units -all --state=inactive

[linux]
[group('services')]
list-failed:
  systemctl list-units -all --state=failed

[linux]
[group('services')]
list-systemd:
  systemctl list-units systemd-*


# =================================================
#
# Nixpkgs Review via Github Action
# https://github.com/ryan4yin/nixpkgs-review-gha
#
# =================================================

# Run nixpkgs-review for PR
[linux]
[group('nixpkgs')]
pkg-review pr:
  gh workflow run review.yml --repo ryan4yin/nixpkgs-review-gha -f x86_64-darwin=no -f post-result=true -f pr={{pr}}

# Run package tests for PR
[linux]
[group('nixpkgs')]
pkg-test pr pname:
  gh workflow run review.yml --repo ryan4yin/nixpkgs-review-gha -f x86_64-darwin=no -f post-result=true -f pr={{pr}} -f extra-args="-p {{pname}}.passthru.tests"

# View the summary of a workflow
[linux]
[group('nixpkgs')]
pkg-summary:
  gh workflow view review.yml --repo ryan4yin/nixpkgs-review-gha
