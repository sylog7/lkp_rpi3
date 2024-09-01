# enable uart in raspberr pi 3 B

## raspi-config
~~~
Select "Interface Option -> Serial", enable.
Select "Interface Option -> Blutooth", disable
~~~

## config.txt
왜 그런지 모르겠는데, ssh로 raspberry pi에 연결해서  
boot/firmware/config.txt를 수정해줘야만 정상적으로 적용됬다.  
그냥 hdmi로 raspberry pi에 연결해도 될것 같다.  
sdcard를 PC에서 열어서 config.txt를 수정하면 제대로 반영이 안되는데,  
왜 그런지는 모르겠다.  
~~~bash
[all]
enable_uart=1
dtoverlay=pi3-disable-bt
~~~

## cmdline.txt
quiet를 제거해야만 부팅로그가 모두 나온다.
제거하지 않으면 부팅로그는 안나오고 로그인 쉘만 표시된다.
