# life

This repo is a minimalist implementation of the ``Conway's Game of Life`` in ``IA-32 Assembly`` using
``ANSI/TERM`` to handle the "graphic" stuff. Until now it was written to run on the following platforms:

![Linux](https://github.com/rafael-santiago/life/blob/master/etc/small-tux.jpg "Linux") ![FreeBSD](https://github.com/rafael-santiago/life/blob/master/etc/small-beastie.jpg "FreeBSD") ![OpenBSD](https://github.com/rafael-santiago/life/blob/master/etc/small-puffy.jpg "OpenBSD") ![NetBSD](https://github.com/rafael-santiago/life/blob/master/etc/small-netbsd-flag.jpg "NetBSD") ![MINIX](https://github.com/rafael-santiago/life/blob/master/etc/small-raccoon.jpg "MINIX") ![SOLARIS](https://github.com/rafael-santiago/life/blob/master/etc/small-solaris-sun.jpg "Solaris") ![Windows](https://github.com/rafael-santiago/life/blob/master/etc/small-windows-logo.jpg "Windows... Sorry, I was not able to find any decent logo... It will be changed soon...")

## How to clone it?

Pretty simple:

```
you@SilvergunSuperman:~/src# git clone https://github.com/rafael-santiago/life life
```

Done.

## How to build it?

I have written it using the ``GNU's Assembler`` (a.k.a ``gas``). You can use the build system or do it
on your own (in this case my code is using the ``libc``). If you are on ``Windows`` is the
``GCC`` is also needed because we use it to link, otherwise the linking would be much harder there.

This tiny project uses my own [build system](https://github.com/rafael-santiago/hefesto). After following
all steps to put ``hefesto`` to work on your system, you should "teach" your build system copy how to handle the
``GNU's Assembler``. You need three commands:

```
root@SilvergunSuperman:~/src# git clone https://github.com/rafael-santiago/helios helios
root@SilvergunSuperman:~/src# cd helios
root@SilvergunSuperman:~/src/helios# hefesto --install=gnu-asm-toolset
```

Done.

After doing it your ``hefesto`` copy will know how to handle the assembler that we need. By the way, your
``helios`` copy can be removed...

Now, inside your ``life`` copy, move to the ``src`` sub-directory and just call ``hefesto`` from there.

```
you@SilvergunSuperman:~/src/life# cd src
you@SilvergunSuperman:~/src/life/src# hefesto
```

An ``ELF`` called ``life`` will be created under the path ``../bin`` and that's it.

If for some reason you are wanting a debug version of it:

```
you@SilvergunSuperman:~/src/life/src# hefesto --compile-model=debug
```

...and good luck! ;)

If you prefer/need to inform your dynamic loader path, try to use the option ``--ld-path`` when calling ``hefesto``:

```
you@SilvergunSuperman:~/src/life/src# hefesto --ld-path=/usr/libexec/ld-elf.so.1
```

If you are having some problem related with the target architecture, you should try:

```
you@SilvergunSuperman:~/src/life/src# hefesto --address-model=32
```

### I still prefer building it by myself...

I think that ``ASSEMBLY`` people are not choosy, so build it by hand is pretty straightforward for them. Even so I took care
to write all this stuff in one single file (``src/life.s``). If you are on a platform listed in **Table 1** you should add to
your ``as`` (Ha-Ha) command the option ``-dsym SYMBOL=1``. In **Table 1** you can find the correct symbol to your current
platform.

AFAIK, on ``Solaris`` the ``as`` is related to its native Assembler, due to it you should call ``gcc`` or ``"gas"``
instead of using your good and old ``"as"``, *BA DUM TSSS* ... Now if you do not have the ``GNU Assembler`` installed on
your ``Solaris`` box I would say that your system by now is out of gas... *BA DUM TSSS*... Anyway, install it because I am
not intending to rewrite all the code stuff only for tan as... *BA DUM TSSS*... Horrible, well, getting back to **Table 1**...

**Table 1**: A thing that you probably already know.

| **Platform**                                                                                                            |    **SYMBOL**    |
|:-----------------------------------------------------------------------------------------------------------------------:|:----------------:|
| ![FreeBSD](https://github.com/rafael-santiago/life/blob/master/etc/small-beastie.jpg "FreeBSD")                         |  ``__FreeBSD__`` |
| ![OpenBSD](https://github.com/rafael-santiago/life/blob/master/etc/small-puffy.jpg "OpenBSD")                           |  ``__OpenBSD__`` |
| ![NetBSD](https://github.com/rafael-santiago/life/blob/master/etc/small-netbsd-flag.jpg "NetBSD")                       |  ``__NetBSD__``  |
| ![Windows](https://github.com/rafael-santiago/life/blob/master/etc/small-windows-logo.jpg "Windows... ¬¬")              |  ``_WIN32``      |

Yes! The same macros that we commonly use when writing ``C`` programs... I love smart people!
Always honoring the memory of a rebel monkey that came down from the tree and started all this shit... that's it! :)

I also love good conventions...

## How to install it?

Being under the ``src`` sub-directory you should do the following:

```
you@SilvergunSuperman:~/src/life/src# hefesto --install
```

If your ``UNIX-like`` has the directory ``/usr/games``, ``life`` will be installed there. On some ``UNIXes`` this directory
is not exported, so you should call ``/usr/games/life`` instead of ``life``. On ``Windows`` it will be installed on ``C:\life``.

If you want to uninstall:

```
you@SilvergunSuperman:~/src/life/src# hefesto --uninstall
```

## How to use it?

This application works based on command line, if you call on your console just ``life`` without passing any argument, as a result
you will see a black screen. You need to inform the initial state of the board and also can inform other things if you want to. Take a look
at the **Table 2** to see more about these command line options.

**Table 2**: Supported command line options until now.

|**Option**| **Description** | **Passing sample** |
|:--------:|----------------:|:----------:|
|``--interactive``          | Indicates that before each new generation an ``ENTER`` is expected | ``life --interactive`` |
|``--alive-color=color``  | Defines the color for representing alive cells. The colors should  be: ``black``, ``red``, ``green``, ``blue``, ``magenta``, ``cyan`` or ``white`` | ``life --alive-color=cyan`` |
|``--dead-color=color``   | Defines the color for representing dead cells. The colors should be: ``black``, ``red``, ``green``, ``blue``, ``magenta``, ``cyan`` or ``white`` | ``life --alive-dead=green`` |
|``--delay=milliseconds`` | Indicates the amount of times (in milliseconds) to wait before the next generation | ``life --delay=1000`` |
|``--generation-nr=n``      | Sets a limit for the game loop | ``life --generation=100`` |
|``--board-size=n``         | Defines the size of the square shaped board. The values should be between ``2`` and ``45`` | ``life --board-size=10`` |
|``--y,x.``        | Makes a cell under (y;x) coordinate alive | ``life --0,0.`` |
| ``--no-ansi-term`` | Inhibits the usage of ``ANSI/TERM`` resources | ``life --no-ansi-term`` |

On ``Windows`` is possible to get a colored output if you run the program from ``MSYS`` or ``Cygwin``. Still on ``Windows`` if you are
using a normal command prompt, the program will detect it and use ``--no-ansi-term`` automatically, you do not have to worry about.

Let's start with a block at the beginning of the board:

```
you@SilvergunSuperman:~/src/life/src# life --0,0. --0,1. \
> --1,0. --1,1.
```

Now let's define a blinker, using the color ``magenta`` for the alive cells.


```
you@SilvergunSuperman:~/src/life/src# life --2,1. \
> --2,3. --2,4. --alive-color=magenta
```

The **Table 3** gathers famous patterns.

**Table 3**: Some oscillators.

| **Pattern** |                                      **Sample**                                      |
|:-----------:|:------------------------------------------------------------------------------------:|
| ``Blinker`` | ![blinker](https://github.com/rafael-santiago/life/blob/master/etc/life-blinker.gif) |
| ``Beacon``  | ![beacon](https://github.com/rafael-santiago/life/blob/master/etc/life-beacon.gif)   |
| ``Toad``    | ![toad](https://github.com/rafael-santiago/life/blob/master/etc/life-toad.gif)       |
| ``Pulsar``  | ![pulsar](https://github.com/rafael-santiago/life/blob/master/etc/life-pulsar.gif)   |

For example, to produce the Pulsar oscillator in **Table 3**, I have used the following command line:

```
you@SilvergunSuperman:~/src/life/src# life --2,4. --2,5. --2,6. \
> --4,2. --5,2. --6,2. \
> --4,7. --5,7. --6,7. \
> --7,4. --7,5.  --7,6. \
> --2,10. --2,11. --2,12. \
> --4,9. --5,9. --6,9. \
> --7,10. --7,11. --7,12. \
> --4,14. --5,14. --6,14. \
> --9,4. --9,5. --9,6. \
> --10,2. --11,2. --12,2. \
> --14,4. --14,5. --14,6. \
> --10,7. --11,7. --12,7. \
> --9,10. --9,11. --9,12. \
> --10,9. --11,9. --12,9. \
> --14,10. --14,11. --14,12. \
> --10,14. --11,14. --12,14. \
> --delay=500 --alive-color=cyan
```
Yes, it is not for cowards..

To exit the program you should hit ``CTRL + c``. In some shell types you must confirm it with an ``ENTER``.

## .*

*(((coming soon)))*
