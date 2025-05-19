# playbook-kali

## Bootstrap Script

A bootstrap script is provided to automically install ansible and required packages prior to running the playbook.

Because the script must be run with `sudo`, an Ansible vault is not required.

### Running The Script

```
chmod +x bootstrap.sh
sudo ./bootstrap.sh
```

## Ansible Playbook

### Running The Playbook (Manually)

#### Requirements

Superuser priviledges are required by the playbook.
  
Create a `secrets.yml` file with the vault password `kali`, replace `YOURSUDOPASSWORD` with your sudo password:
  
  ```
  ansible-vault encrypt_string 'YOURSUDOPASSWORD' \
  --name 'ansible_become_pass' >> secrets.yml
  ```

If you want to use a different password than `kali`, just make sure the file `.vault_pass.txt` contains the right password.

#### Commands

Note: Run without a vault using `sudo`, you can then remove the `--vault-password-file .vault_pass.txt` switch.

Run all roles:

`ansible-playbook playbook.yml --connection=local --vault-password-file .vault_pass.txt`

Run only specified roles -- multiple `--tags` can be specified:

`ansible-playbook playbook.yml --connection=local --vault-password-file .vault_pass.txt --tags <role>`

Run all but specified roles -- multiple `--skip-tags` can be specified:

`ansible-playbook playbook.yml --connection=local --vault-password-file .vault_pass.txt --skip-tags <role>`