# tvstation
TV station with ad support, random episode playback, and support for playing ads between chapters inside of an episode.
This setup works on Raspberry Pi 5 running bookworm.
       _,met$$$$$gg.          tvbox@tvbox
    ,g$$$$$$$$$$$$$$$P.       -----------
  ,g$$P"     """Y$$.".        OS: Debian GNU/Linux 12 (bookworm) aarch64
 ,$$P'              `$$$.     Host: Raspberry Pi 5 Model B Rev 1.1
',$$P       ,ggs.     `$$b:   Kernel: 6.12.25+rpt-rpi-2712
`d$$'     ,$P"'   .    $$$    Uptime: 20 mins
 $$P      d$'     ,    $$P    Packages: 1683 (dpkg)
 $$:      $$.   -    ,d$$'    Shell: bash 5.2.15
 $$;      Y$b._   _,d$P'      Resolution: 1280x720
 Y$$.    `.`"Y$$$$P"'         Terminal: /dev/pts/1
 `$$b      "-.__              CPU: (4) @ 2.400GHz
  `Y$$                        Memory: 768MiB / 4046MiB
   `Y$$.
     `$$b.
       `Y$$b.
          `"Y$b._
              `"""

        
You will also need to compile xwinwrap for the overlay. all prerequisites are in ./install.sh
https://github.com/mmhobi7/xwinwrap
