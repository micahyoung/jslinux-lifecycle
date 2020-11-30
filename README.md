# Run buildpacks lifecycle in JSinux

## Usage
* On workstation, run `./makeroot.sh` (or download and extract latest [release](https://github.com/micahyoung/jslinux-lifecycle/releases)) to create binaries in `./root/`
* Visit https://bellard.org/jslinux/vm.html?url=alpine-x86.cfg&mem=192
* Click "Upload files" `⬆` and select all files in `./root/`
  * `crane`
  * `registry`
  * `lifecycle`
  * `test.sh`
* On JSlinux VM, run `sh test.sh`


## Notes
* `registry` is run in the background since JSLinux has a extremely limited proxy for external network connectivity (though you can run your own [proxy](https://github.com/benjamincburns/websockproxy/) which JSLinux can [use](https://bellard.org/jslinux/faq.html#:~:text=net_url)).
* Uses i386-compiled lifecycle since JSLinux is limited to i386 or riscv.
* JSLinux has an enhanced version at [vfsync.org](https://vfsync.org/vm.html) which can potentially be used to save changes or share a filesystem.
