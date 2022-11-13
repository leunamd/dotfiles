# Dotfiles - managed with chezmoi

## Bitwarden
### Installation
[Bitwarden CLI](https://bitwarden.com/help/cli/) required to run.

- Download from [here](https://vault.bitwarden.com/download/?app=cli&platform=linux)
- Extract 'bw' into ~/bin
- Run command: <pre>chmod +x ~/bin/bw</pre>

### Login
```sh
bw login
bw unlock
export BW_SESSION="<BITWARDEN_SESSION_TOKEN>"
```

## Chezmoi
### Add file

```sh
chezmoi add <path/to/file>
```

### Add encrypted file

```sh
chezmoi add --encrypt <path/to/file>
```

### Add file with template

```sh
chezmoi add --template <path/to/file>
```

### Save file in bitwarden

```sh
echo "{\"organizationId\":null,\"folderId\":\"d8913fd4-f437-455f-9f8d-af3501041293\",\"type\":2,\"name\":\"<bitwarden_name>\",\"notes\":\"$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' <path/to/file> && echo '\n' )\",\"favorite\":false,\"fields\":[],\"login\":null,\"secureNote\":{\"type\":0},\"card\":null,\"identity\":null}" | bw encode | bw create item
```

### Add bitwarden note reference to template file

```sh
chezmoi cd
echo -n '{{ (bitwarden "item" "<bitwarden_name>").notes }}' > <path/to/file.tmpl>
```


### Remember to always edit source file

chezmoi apply --verbose --destination /Users/bric3/tmphome --dry-run
```sh
chezmoi edit <path/to/file>
```
instead of
```sh
vim <path/to/file>
```


### Check if templates work

remember to remove --dry-run when you want to populate the directory
```sh
chezmoi apply --verbose --destination <tmp_destination_directory> --dry-run
```

## Sync on another machine
Remember to login first into bitwarden, unlock the vault and export BW_SESSION. Instructions [here](#login) 
### One-liner

```sh
chezmoi init --apply https://github.com/username/dotfiles.git
```

### Multiple commands
On a second machine, initialize chezmoi with your dotfiles repo:
```sh
chezmoi init https://github.com/username/dotfiles.git
```
This will check out the repo and any submodules and optionally create a chezmoi config file for you.
Check what changes that chezmoi will make to your home directory by running:

```sh
chezmoi diff
```
If you are happy with the changes that chezmoi will make then run:
```sh 
chezmoi apply -v
```
If you are not happy with the changes to a file then either edit it with:
```sh
chezmoi edit $FILE
```
Or, invoke a merge tool (by default vimdiff) to merge changes between the current contents of the file, the file in your working copy, and the computed contents of the file:
```sh
chezmoi merge $FILE
```
On any machine, you can pull and apply the latest changes from your repo with:
```sh
chezmoi update -v
```
