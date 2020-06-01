# numerical-calculation-with-crystal

Source files for numerical calculation in Crystal
http://jun-makino.sakura.ne.jp/articles/intro_crystal/face.html

This include basic tools to do experiments wot self-gravitation
particle systems

mkplummer : create a Plummer model in the standard unit (similar to
NEMO mkplummer)

nacsplot2 : plotting package to show the distribution of particles
(similar to NEMO snapplot)

hackcode1 : A simple Barnes-Hut treecode

You might want to use fdpscr https://github.com/jmakino/crystalfdps.

To cmpile, after you download (or git clone)

```
   cd src
   shards install
   make all
```


