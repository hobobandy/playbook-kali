# playbook-kali

## Prior to running the playbook

* Create a `secrets.yml` file with the vault password `kali`, replace `YOURSUDOPASSWORD` with your sudo password:
  
  ```
  ansible-vault encrypt_string 'YOURSUDOPASSWORD' \
  --name 'ansible_become_pass' >> secrets.yml
  ```

## Running the playbook

```
chmod +x bootstrap.sh
./bootstrap.sh
```

OR

`ansible-playbook playbook.yml --connection=local --vault-password-file .vault_pass.txt`

OR

`ansible-playbook playbook.yml --connection=local --vault-password-file .vault_pass.txt --tags <role>`