# life

This repo is a minimalist implementation of the ``Conway's Game of Life`` in ``IA-32 Assembly`` using
``ANSI/TERM`` to handle the "graphic" stuff.

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

## How to install it?

*(((coming soon)))*

## How to use?

*(((coming soon)))*

## .*

*(((coming soon)))*
