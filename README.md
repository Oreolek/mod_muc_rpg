Prosody RPG module
==================

This is a module for Prosody 0.9 (maybe lower, but only maybe) that adds /roll command to every MUC.

The syntax is this:

    /roll <times>d<sides>+<bonus>
    /roll <times>d<sides>-<bonus>

The `<times>` bit is optional (default 1), the `d` letter is optional too if `times` = 1 and `bonus` = 0.

Example:
    /roll 1d4
    /roll 2d5-2
    /roll d20+3
    /roll 20

Installation
------------
This module uses Mersenne-Twister random-number library for better random number generation.

You can get the newest library version [here.](http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/emt19937ar.html)

The library uses BSD license so it's included here (for Lua 5.2). Just compile the `random.so` and put it in plugin directory.

Then, drop the module to Prosody dir (usually `/usr/lib/prosody/modules`) and turn it on in your config.
