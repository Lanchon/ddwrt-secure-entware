# Entware Over SSL/TLS For DD-WRT Installations

All software for DD-WRT routers from official Entware, including installation scripts, packet manager bootstrapping, and installable packages, is distributed though the open Internet via HTTP without any kind of security. This is unacceptable: any actor between Entware's repository and DD-WRT clients can trivially and completely pwn the clients.

Fortunately, Entware servers do support HTTPS. This repo provides tools that take advantage of this fact in order to allow fully secure Entware installtions on DD-WRT devices.

### Secure Entware Installation

Prerequisite: a Linux filesystem partition on non-volatile storage auto-mounted on `/opt` (preferably formatted as ext4).

0. If you have already installed Entware though insecure HTTP before, consider the possibility that your router may have been pwned. You might want to wipe `/opt`, reflash DD-WRT, and reset to factory defaults.

1. Run these commands on the DD-WRT router via SSH or Telnet:
   ```
   cd /opt
   wget 'https://raw.githubusercontent.com/Lanchon/ddwrt-secure-entware/master/patch-installer.sh'
   ```
   As of October 2019, official builds of DD-WRT include a version of `wget` that does not support SSL/TLS (HTTPS URLs), so the previous `wget` command is expected to fail. If this is the case, [install Curlize](#curlize-installation) as explained bellow. Once that is done, restart the secure Entware installation [from the top](#secure-entware-installation). The above `wget` command should now work.

2. Check your router's architecture:
   ```
   uname -m
   ```

3. Fetch the Entware install script that corresponds to your hardware architecture as explained in regular Entware install how-to's, but **make sure to replace the URL's protocol identifier from 'http:' to 'https:'**.

   * For **ARMv7** architecture:
     ```
     wget 'https://bin.entware.net/armv7sf-k3.2/installer/generic.sh'
     ```

   * For **MIPSEL** architecture:
     ```
     wget 'https://bin.entware.net/mipselsf-k3.4/installer/generic.sh'
     ```

   * For **MIPS** architecture:
     ```
     wget 'https://bin.entware.net/mipssf-k3.4/installer/generic.sh'
     ```

4. Patch the installer you just downloaded to make it work via HTTPS and run it:
   ```
   sh patch-installer.sh generic.sh
   sh generic.sh
   ```

5. Add this line at the **end** of the **startup** script in DD-WRT's **Administration/Commands**:
   ```
   /opt/etc/init.d/rc.unslung start
   ```

6. And add this line at the **beginning** of the **shutdown** script in DD-WRT's **Administration/Commands**:
   ```
   /opt/etc/init.d/rc.unslung stop
   ```


# Curlize

The installation scripts and packet manager of the official Entware distribution use `wget` to access the network. Unfortunately, as of October 2019, official builds of DD-WRT include a version of `wget` that does not support SSL/TLS (HTTPS URLs). But on the other hand, the version of `curl` shipped with DD-WRT does support HTTPS.

Curlize is a simple script that intercepts a few hand-picked command-line formats used by Entware to invoke `wget`, and fulfills those requests using `curl` instead, thus allowing HTTPS URLs. All other non-matching invocations formats are passed verbatim to `wget`. Note that Curlize will never intercept non-HTTPS requests, meaning that the all `wget` invocations that are affected by Curlize were destined to fail anyway.

### Curlize Installation

1. Run these commands on the DD-WRT router via SSH or Telnet:
   ```
   mkdir -p /opt/bin-override /opt/sbin-override
   cd /opt/bin-override
   curl -fO 'https://raw.githubusercontent.com/Lanchon/ddwrt-secure-entware/master/curlize-wget'
   chmod +x curlize-wget
   ln -s curlize-wget wget
   ```

2. Add these lines at the **beginning** of the **startup** script in DD-WRT's **Administration/Commands**:
   ```
   echo 'export PATH="/opt/bin-override:/opt/sbin-override:$PATH"' >>/tmp/root/.profile
   chmod +x /tmp/root/.profile
   ```

3. And reboot the router.
