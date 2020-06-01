# numerical-calculation-with-crystal

Source files for numerical calculation in Crystal
http://jun-makino.sakura.ne.jp/articles/intro_crystal/face.html

This include basic tools to do experiments wot self-gravitation
particle systems

mkplummer : create a Plummer model in the standard unit (similar to
NEMO mkplummer)

nacsplot3 : plotting package to show the distribution of particles
(similar to NEMO snapplot)

hackcode1 : A simple Barnes-Hut treecode

nacsshift : shift position and velocity

nacsadd : add multiple snap shot files 


You might want to use fdpscr https://github.com/jmakino/crystalfdps.

To cmpile, after you download (or git clone)

```
   cd src
   shards install
   make all
```
All programs come with fairly long help message. Try, e.g.,

```
   mkplummer -h
```   


![simulation sample output](./images/4kcollide.gif)

This sample is created by:

```
 ./mkplummer -n 2048 -Y -s 1 > p2k.yml
 nacsshift < p2k.yml > tmp0 -x -3,0,0 -v 0.3,-0.2,0
 nacsshift < p2k.yml > tmp1 -x 3,0,0 -v -0.3,0.2,0
 nacsadd -r -i tmp0,tmp1 > 4k.yml
 env LD_LIBRARY_PATH=../../src/fdps-crystal/ ~/src/fdps-crystal/fdpscr -O 4k-out.yml -t 40 -d 1 -o 0.125 -T 0.5 < 4k.yml 
 env GKS_WSTYPE=gif nacsplot3 < 4k-out.yml -w 10 &
```
