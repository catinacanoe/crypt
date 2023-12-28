vim:ft=markdown

[https://github.com/catinacanoe/crypt](https://github.com/catinacanoe/crypt)
`crypt`, a utility that uses gpg encryption to allow you to securely store data on github (it also bypasses the file size limit)

# Features

  - Sync private data between multiple machines
  - Have the history of your data fully saved
  - Data is fully encrypted with gpg everywhere, except locally (for obvious reasons)
  - Sync (pull or push) automatically, just by running one command
  - Optimized for network and system resources: only encrypt/decrypt and upload/download data that has been changed
  - Bypasses filesize limit (by splitting large files behind the scenes). So, you can store files over 50M on github (such as textbook pdfs)

# Non-Features
  
  - not decentralized: if your github repo is destroyed, you can no longer sync (but no data is lost)
  - data structure is not encrypted: anyone who has access to your repo (github, microsoft, ...) can see the folders and file names (and file sizes) of your crypt

# Installation

  Clone this repository: `git clone 'https://github.com/catinacanoe/crypt.git'`.
  All of the functionality is stored inside `main.sh`, so all you need to do is set an alias (or anything equivalent) like this: `alias crypt="/path/to/repo/crypt/main.sh"` in your `.bashrc` or `.zshrc`.
  You must also set an environment variable `$CRYPT_RECIPIENT` to the email of the gpg key you want to use with crypt. You can see this email by running `gpg --list-keys`. The output should look like this:
  ```
  /home/username/.gnupg/pubring.kbx
  ------------------------------
  pub   rsa4096/0x0123456789ABCDEF 2001-01-01 [SC]
        Key fingerprint = 0123 4567 89AB CDEF 0123  4567 89AB CDEF 0123 4567
  uid                   [ultimate] myname (my key description) <thisiswhatyouneed@mail.com>
  sub   rsa4096/0x0123456879ABCDEF 2001-01-01 [E]

  .
  ..
  ...
  ```
  In this case, I would set the environment variable `$CRYPT_RECIPIENT` to `thisiswhatyouneed@mail.com` (the string enclosed in `<angle brackets>` on the `uid` line)

## NixOS

   I personally use nixos, and there is a really nice way to install stuff like this. With `home.nix` use:
   `home.packages = [ (pkgs.writeShellScriptBin "crypt" "/path/to/repo/crypt/main.sh $@") ];`

   And with `configuration.nix`, use:
   `environment.systemPackages = [ (pkgs.writeShellScriptBin "crypt" "/path/to/repo/crypt/main.sh $@") ];`
   
   To set the environment variable, you can put this into your `home.nix`:
   `home.sessionVariables.CRYPT_RECIPIENT = "thisiswhatyouneed@mail.com";`

# Usage

  Similar to `git`, you can just run `crypt` with an argument which is basically just a subcommand that dictates what happens.
  Note `.crypt/` refers to the folder of that name that is in every crypt repo (it stores the file index and all of the encrypted files), while `crypt` refers to the unencrypted data stored locally.
  These are all of the valid subcommands and their arguments:

## check
   
   (no arguments)
   This subcommand just checks if the current directory is a `crypt` repository (or a child directory of one). If this is a `crypt`, this subcommand silently exits with no error. If it is not a `crypt`, this will print an error message and exit with an error. Btw, this is used by all other subcommands (except `clone` and `init`) so that they don't run in directories that are not crypts.

## status

   (no arguments)

   Does its best to give you info about the state of the local repo in comparison with remote repo state. No guarantees about the state of `.crypt/` after calling this (either it is consistent with remote, or local `crypt` state). But the local `crypt` is not modified by calling this. All it does is try to figure out if the repo is behind, up to date, or ahead of remote. Any complicated cases like remote and local having new and conflicting commits are undefined behavior (expects up to date, only remote has new commits, or only local has new commits). It's not very smart, but super convenient if you keep your remote up to date. The last line printed is one of these:
   ```
   this crypt is behind the remote
   this crypt is ahead of remote
   this crypt is up to date with remote
   ```

## sync

   (no arguments)

   Attempts get the local and remote repositories synced (push or pull). It uses the `status` subcommand to get the current repo state. Then if everything is up to date, it does nothing. If the local repo is behind, it just calls the `decrypt` subcommand (since `status` will have already called `fetch`). If the local repo is ahead of remote, it just calls the `commit` and `push` subcommands (since `status` will have already called `encrypt`). Again, any complicated remote/local cases are undefinhed behaviour (uncertainty propagates from `status`).

## clone

   Arguments:
   1. url of remote repository to clone
   2. name of the target directory to clone into

   This subcommand will create the target directory, correctly clone the `.crypt/` folder from the remote, and then decrypt the data that it pulled.

## init

   Arguments:
   1. url of remote repository to push this new data to (should be a fresh, empty repo)

   All this does is just take the data currently in this folder, and create a `crypt` with it, synced with a remote repo. It correctly creates a `.gitignore` and the whole file structure of a `crypt`. Then it pushes everything to the passed remote.

## decrypt

   (no arguments)

   This subcommand will just read the `.crypt/index` file to see which files have been marked as modified or deleted since the last call to `decrypt`. (It does not update or fetch to `.crypt/`) Then, it will delete those files as marked, or if they were marked as modified, it will decrypt the files from `.crypt/` and replace the files in the `crypt` with that new data.

## encrypt

   (no arguments)

   Saves the old state of the `.crypt/` data, and then goes through the entire `crypt`, encrypting all modified/new files and deleting the deleted ones. It determines whether or not a file has been modified by comparing the current and old `sha256sum`. If it is not changed, it will just reuse old data. If it has been changed, the hash file is updated, and the file is re-encrypted using gpg.

## fetch

   (no arguments)

   Fetches the latest `.crypt/` data from remote, and updates the `.crypt/index` file to reflect any newly modified or deleted files in all of the commits that have been fetched. (guarantees that there are no duplicate lines in the index) Then it merges the data into `.crypt/` (but doesn't decrypt it, so this doesn't affect the state of the local `crypt`)

## pull

   (no arguments)

   Literally all this does is `crypt fetch && crypt decrypt`. Just pulls any new data from the remote, and decrypts any modified files.

## push

   (no arguments)

   All this does is call `git push` from inside the `.crypt/` folder. This should not be called by the end user.

## commit

   (no arguments)

   You shouldn't need to use this subcommand as an end user, but all it does is `git add` and `commit` the data currently in the `.crypt/` folder. It is not guaranteed to be reflective of the currently state of the crypt (ie it doesn't encrypt the data into `.crypt/` it just uses whatever is already there)

## decrypt-item (`decrypt_item`)

   Arguments:
   1. The item to decrypt (can be a file or folder)

   As an end user, you should not use this subcommand, other than `crypt decrypt_item .`. What that will do is forcefully decrypt everything stored in `.crypt/` and replace whatever is currently in the `crypt`. You might need this since `crypt decrypt` will only decrypt data that is marked as modified in the index file (which is updated every time you `crypt fetch`).
   Other than that you probably shouldn't use this command. The first argument must either be a folder or a `.hash` file stored inside `.crypt/` (relative path from inside `.crypt/`). This will just recursively decrypt that item and update the `crypt` with that new data.

## encrypt-item (`encrypt_item`)

   Do not call this subcommand as an end user. It expects a certain environment produced by other subcommands. Calling this as a standalone is undefined behavior.

