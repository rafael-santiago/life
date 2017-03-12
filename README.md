# life

This repo is a minimalist implementation of the ``Conway's Game of Life`` in ``IA-32 Assembly`` using
``ANSI/TERM`` to handle the "graphic" stuff. Until now it was written to run on ``Linux`` and ``FreeBSD``.

## How to clone it?

Pretty simple:

```
you@SilvergunSuperman:~/src# git clone https://github.com/rafael-santiago/life life
```

Done.

## How to build it?

I have written it using the ``GNU's Assembler`` (a.k.a ``gas``). You can use the build system or do it
by your own (in this case my code is using the ``libc``).

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

## How to install it?

Being under the ``src`` sub-directory you should do the following:

```
you@SilvergunSuperman:~/src/life/src# hefesto --install
```

If you want to uninstall:

```
you@SilvergunSuperman:~/src/life/src# hefesto --uninstall
```

## How to use it?

This application works based on command line, if you call on your console just ``life`` without passing any argument, as a result
you will see a black screen. You need to inform the initial state of the board and also can inform other things if you want to. Take a look
at the **Table 1** to see more about these command line options.

**Table 1**: Supported command line options until now.

|**Option**| **Description** | **Passing sample** |
|:--------:|----------------:|:----------:|
|``--interactive``          | Indicates that before each new generation an ``ENTER`` is expected | ``life --interactive`` |
|``--alive-color=color``  | Defines the color for representing alive cells. The colors should  be: ``black``, ``red``, ``green``, ``blue``, ``magenta``, ``cyan`` or ``white`` | ``life --alive-color=cyan`` |
|``--dead-color=color``   | Defines the color for representing dead cells. The colors should be: ``black``, ``red``, ``green``, ``blue``, ``magenta``, ``cyan`` or ``white`` | ``life --alive-dead=green`` |
|``--delay=milliseconds`` | Indicates the amount of times (in milliseconds) to wait before the next generation | ``life --delay=1000`` |
|``--generation-nr=n``      | Sets a limit for the game loop | ``life --generation=100`` |
|``--board-size=n``         | Defines the size of the square shaped board. The values should be between ``2`` and ``45`` | ``life --board-size=10`` |
|``--alive-y-x``        | Makes a cell under (y;x) coordinate alive | ``life --alive-0-0`` |

Let's start with a block at the beginning of the board:

```
you@SilvergunSuperman:~/src/life/src# life --alive-0-0 --alive-0-1 \
> --alive-1-0 --alive-1-1
```

Now let's define a blinker, using the color ``magenta`` for the alive cells.


```
you@SilvergunSuperman:~/src/life/src# life --alive-2-1 \
> --alive-2-3 --alive-2-4 --alive-color=magenta
```

The **Table 2** gathers famous patterns.

**Table 2**: Some oscillators.

| **Pattern** |                                      **Sample**                                      |
|:-----------:|:------------------------------------------------------------------------------------:|
| ``Blinker`` | ![blinker](https://github.com/rafael-santiago/life/blob/master/etc/life-blinker.gif) |
| ``Beacon``  | ![beacon](https://github.com/rafael-santiago/life/blob/master/etc/life-beacon.gif)   |
| ``Toad``    | ![toad](https://github.com/rafael-santiago/life/blob/master/etc/life-toad.gif)       |
| ``Pulsar``  | ![pulsar](https://github.com/rafael-santiago/life/blob/master/etc/life-pulsar.gif)   |

For example, to produce the Pulsar oscillator in **Table 2**, I have used the following command line:

```
you@SilvergunSuperman:~/src/life/src# life --alive-2-4 --alive-2-5 --alive-2-6 \
> --alive-4-2 --alive-5-2 --alive-6-2 \
> --alive-4-7 --alive-5-7 --alive-6-7 \
> --alive-7-4 --alive-7-5  --alive-7-6 \
> --alive-2-10 --alive-2-11 --alive-2-12 \
> --alive-4-9 --alive-5-9 --alive-6-9 \
> --alive-7-10 --alive-7-11 --alive-7-12 \
> --alive-4-14 --alive-5-14 --alive-6-14 \
> --alive-9-4 --alive-9-5 --alive-9-6 \
> --alive-10-2 --alive-11-2 --alive-12-2 \
> --alive-14-4 --alive-14-5 --alive-14-6 \
> --alive-10-7 --alive-11-7 --alive-12-7 \
> --alive-9-10 --alive-9-11 --alive-9-12 \
> --alive-10-9 --alive-11-9 --alive-12-9 \
> --alive-14-10 --alive-14-11 --alive-14-12 \
> --alive-10-14 --alive-11-14 --alive-12-14 \
> --delay=500 --alive-color=cyan
```
Yes, it is not for cowards..

To exit the program you should hit ``CTRL + c``. In some shell types you must confirm it with an ``ENTER``.

## .*

*(((coming soon)))*
