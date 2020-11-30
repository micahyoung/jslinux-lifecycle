# run lifecycle in jslinux

## Usage
* On workstation, run `./makeroot.sh` (or download and extract latest [release](https://github.com/micahyoung/jslinux-lifecycle/releases)) to create binaries in `./root/`
* Visit https://bellard.org/jslinux/vm.html?url=alpine-x86.cfg&mem=192
* Click "Upload files" `⬆` and select all files in `./root/`
  * `crane`
  * `registry`
  * `lifecycle`
  * `test.sh`
* On jslinux, run `sh test.sh`
