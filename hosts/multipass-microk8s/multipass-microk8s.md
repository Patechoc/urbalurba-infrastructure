# multipass-microk8s

Provisioning kubernetes (microk8s) on ubuntu running in multipass.

This is only a good idea if you want to test the system on your local machine. I used it to test the setup before for provisioning on a physical ubuntu server.

The host that is created is named: multipass-microk8s

Below is a manual description of how to set up the VM multipass-microk8s. There is also a script that does it all.
The script in the root folder named `ìnstall-all.sh` will run the scripts here. So all the stuff here describes how to do it manually.

## create the VM named multipass-microk8s

Make sure you are in the folder `hosts/multipass-microk8s` when you run the script.

Default the script will create a VM with so small resources that it can only be used to verifi that GitOps works. If you want to use it for development you must provide parameters that give it more resources.
Run it with the command:


For development (we use this):

```bash
cd hosts/multipass-microk8s
./01-create-multipass-microk8s.sh --cpus 6 --memory "10G" --disk "50G"
```

Just for testing use a smaller VM.:

```bash
cd hosts/multipass-microk8s
./01-create-multipass-microk8s.sh
```


The VM is now created. To set it up we use the VM named provision-host.

## Register multipass-microk8s in ansible inventory

For the provision-host VM to be able to reach the multipass-microk8s VM we must set up the ansible inventory file.
This is descibed in the file [provision-host/02-register-ansible-inventory.md](/provision-host/02-register-ansible-inventory.md).

(there is now a script that does this) Taks:

- log in to the provision-host VM
- set up the ansible inventory file
- do the ansible ping to check that the multipass-microk8s VM is reachable

Then return here for instructions on how to install the kubernetes cluster on the multipass-microk8s VM.

## Install microk8s on VM multipass-microk8s running on your host

### The automatic way of installing microk8s on the multipass-microk8s VM


In the folder `hosts/multipass-microk8s`run the script to install microk8s on the VM multipass-microk8s.
A lot of things are done in the script. It will install microk8s, set up the dashboard and set up metallb.

The below example will install microk8s on the VM multipass-microk8s and set up metallb to provide IP addresses in the range 192.168.68.240-192.168.68.242 for the cluster. It means the addresses: 192.168.68.240, 192.168.68.241 and 192.168.68.242

```bash
cd hosts/multipass-microk8s
./03-setup-multipass-microk8s.sh 192.168.68.240-192.168.68.242
```

At the bottom you will see.

```plaintext
------ Summary of installation statuses for: $0 ------
Testing connection to multipass-microk8s: OK
Installing microk8s: OK
Merging kubeconfig files: OK
--------------- All OK ------------------------
Kubernetes Dashboard is accessible on:
<link displayed here>

Click on the link and paste this token:
<token displayed here>    
```

Click on the URL and you should see the Kubernetes dashboard. Use the token to log in.

If it does not work automatically you can do it manually. The manual way is described below.

### The manual way of installing microk8s on the multipass-microk8s VM

The playbook for installing microk8s is `02-install-microk8s.yml` is in the folder playbooks.
It needs two parameters. The hostname and the IP range that the cluster can provide IP addresses from.

For the VM multipass-microk8s the hostname is `multipass-microk8s`.
In order to provide a IP range we must know something about the network that the VM is running on. Running `multipass info multipass-microk8s` will give us the IP address of the VM. In IPv4 there are two adresses listed. One for NAT and one for the local network. We will use the local network address. That is the second address. In my case it is `192.168.68.65`
On my home LAN i know that the addresses above `192.168.68.240` are not used. So I can use the range `192.168.68.240-192.168.68.242` for the cluster. This gives the cluster three IP addresses to use. If you do this on a corporate network you must check with the network administrator what range you can use.

Log in to the provision-host VM and change to the folder `/mnt/urbalurbadisk/ansible`. Run the command:

```bash
ansible-playbook playbooks/02-install-microk8s.yml -e target_host="multipass-microk8s" -e metallb_ip_range="192.168.68.240-192.168.68.242"
```

The install will also set up the dashboard.

The output will show the token and the url to use to log in to the dashboard.

```plaintext
TASK [Display the NodePort for Kubernetes Dashboard for all IPs] ****************************************************************
ok: [multipass-microk8s] => (item=192.168.64.23) => {
    "msg": "Kubernetes Dashboard is accessible on: https://192.168.64.23:31630"
}
ok: [multipass-microk8s] => (item=192.168.68.81) => {
    "msg": "Kubernetes Dashboard is accessible on: https://192.168.68.81:31630"
}
```


Two files are created in `provision-host` folder `/mnt/urbalurbadisk/kubeconfig` the files are:

- multipass-microk8s-dashboardtoken: contains the token for the dashboard
- multipass-microk8s-kubeconfig: contains the kubeconfig file for the cluster

#### Merge the kubeconfig file into one file for all clusters

The kubeconfig file for the cluster is stored in the file `multipass-microk8s-kubeconfig`. As we are setting up more clusters we need to merge the kubeconfig files into one file. This is done with the playbook `04-merge-kubeconf.yml`.

```bash
 ansible-playbook playbooks/04-merge-kubeconf.yml
```

The playbook merges all *-kubeconfig files in the folder `/mnt/urbalurbadisk/kubeconfig` into one file `/mnt/urbalurbadisk/kubeconfig/kubeconf-all`. It then sets the KUBECONFIG environment variable to the file. But in order to use it you must run the command:

```bash
source ~/.bashrc
```

Now you can use the kubectl command to manage the cluster. The commands are described in the file [/commands/kubectl-commands.md](/commands/kubectl-commands.md)

#### Install Helm

Helm is a package manager for kubernetes. It is used to install applications in the cluster. Helm is installed with the playbook playbooks/install-helm.yml

```bash
ansible-playbook playbooks/03-install-microk8s-helm.yml
```

## Log in to the dashboard

Now we need to test if the cluster is working and we can do that by logging in to the dashboard.
Use the url on your host (Mac in my case) computer to log in to the dashboard. As you see there are two IP addresses to use. One for NAT and one that is available on the local network.

So just click on the link and use the token that is in the file `multipass-microk8s-dashboardtoken` to log in.

There is nothing in the cluster yet. To see something you can click on "Nodes" in the left menu and you should see a graph of CPU and memory usage.

We now know that the cluster is working.


## k9s a terminal based UI for kubernetes

k9s is a terminal based UI for kubernetes. It is a great tool to use when you are working in the terminal. When kubectl works you can just start it with the command `k9s` and you will see a UI that is easy to use.
the k9s is installed on the provision-host VM. You can use it from there. 

```bash
k9s
```

## Log in to multipass-microk8s from your computer

To use the multipass-microk8s VM we need to log in to it using ssh key that was created in the secrets step.

```bash
ssh -i ./secrets/id_rsa_ansible ansible@$(multipass info multipass-microk8s | grep IPv4 | awk '{print $2}')
```