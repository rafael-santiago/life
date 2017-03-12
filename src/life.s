/*
 *                                Copyright (C) 2017 by Rafael Santiago
 *
 * This is a free software. You can redistribute it and/or modify under
 * the terms of the GNU General Public License version 2.
 *
 */

.section .data

.equ CELL_BYTES_PER_ROW, 45 /* INFO(Rafael): It should store the real maximum of columns. */

cells:
    .rept (CELL_BYTES_PER_ROW * CELL_BYTES_PER_ROW)
        .byte 0x00
    .endr

.equ CELL_ROW_INITIAL_X, 5

alive_fmt:
    .asciz "\033[40m \033[m"

dead_fmt:
    .asciz "\033[40m \033[m"

gotoxy_fmt:
    .asciz "\033[%d;%dH"

clrscr_fmt:
    .asciz "\033[2J"

newline_fmt:
    .asciz "\n"

alive_cell_nr:
    .int 0

cell_row_min:
    .int 0

cell_col_min:
    .int 0

cell_row_max:
    .int 19

cell_col_max:
    .int 19

color_black:
    .asciz "black"

color_red:
    .asciz "red"

color_green:
    .asciz "green"

color_yellow:
    .asciz "yellow"

color_blue:
    .asciz "blue"

color_magenta:
    .asciz "magenta"

color_cyan:
    .asciz "cyan"

color_white:
    .asciz "white"

colors:
    .int color_black, color_red, color_green, color_yellow, color_blue, color_magenta, color_cyan, color_white

colors_nr:
    .int 8

sigint_watchdog_fmt:
    .asciz "Quit.\n"

option_alive_color:
    .asciz "--alive-color="

err_invalid_alive_color:
    .asciz "ERROR: Invalid alive color.\n"

default_alive_color:
    .int color_red

option_dead_color:
    .asciz "--dead-color="

default_dead_color:
    .int color_black

err_invalid_dead_color:
    .asciz "ERROR: Invalid dead color.\n"

option_interactive:
    .asciz "--interactive"

interactive_mode:
    .int 0

option_generation_nr:
    .asciz "--generation-nr="

default_generation_nr:
    .asciz "0"

generation_nr:
    .int 0

err_invalid_generation_nr:
    .asciz "ERROR: Invalid total of generations.\n"

option_board_size:
    .asciz "--board-size="

default_board_size:
    .asciz "20"

err_invalid_board_size:
    .asciz "ERROR: Invalid board size.\n"

option_delay:
    .asciz "--delay="

default_delay:
    .asciz "200"  /* Although being internally used with usleep this time should be defined here in milliseconds. */

usleep_time:
    .int 200000

err_invalid_delay:
    .asciz "ERROR: Invalid delay value.\n"

test_fmt:
    .asciz "DATA: '%d'\n"

option_cell_fmt:
    .asciz "--alive-%d-%d"

option_version:
    .asciz "--version"

version:
    .asciz "life-v0.1\n"

option_help:
    .asciz "--help"

help:
    .ascii "use: %s [--interactive --alive-color=color --dead-color=color --board-size=n\n"
    .ascii "                            --alive-n-n --delay=[millisecs] --generation-nr=n]\n\n"
    .ascii " * You should try the command 'man life' in order to know how to live with those options listed in the usage "
    .ascii "line.\n\n"
    .ascii "life is licensed under GPLv2. This is a free software. Yes, your life is yours..or at least should be!\n"
    .ascii "life (not your) is Copyright (C) 2017 by Rafael Santiago.\n\n"
    .asciz "Bug reports, feedback, etc: <https://github.com/rafael-santiago/life/issues>\n\n"

quit_game:
    .int 0

.ifdef __FreeBSD__
    /* INFO(Rafael): Trick to link it with libc on FreeBSD. Avoiding undefined reference errors
                        related with the following symbols. */
.globl environ
environ:
    .quad 0

.globl __progname
__progname:
    .asciz "life"

.endif

.ifdef __OpenBSD__
    /* INFO(Rafael): This tag identifies our binary as an OpenBSD ELF,
            otherwise the nosy shell will try to execute it. I hate it.. */
.section ".note.openbsd.ident", "a"
    .align 2
    .int 8
    .int 4
    .int 1
    .asciz "OpenBSD"
    .int 0
    .align 2

.endif

.section .bss
    .lcomm argc, 4

    .lcomm argv, 4

    .lcomm temp_str, 255

.section .text

.globl _start

_start:

    /* INFO(Rafael): No problem on using immediate values for POSIX signals here,
                     they are standard, any decent UNIX will follow them. */

    pushl $sigint_watchdog
    pushl $2
    call signal
    addl $8, %esp

    pushl $sigint_watchdog
    pushl $3
    call signal
    addl $8, %esp

    pushl $sigint_watchdog
    pushl $15
    call signal
    addl $8, %esp

    /* INFO(Rafael): Setting the argc and **argv to the related global variables used by get_option() function.
                     This is stupid and slower considering the context that we are in anyway I prefer doing it. */

    movl %ebp, %edx
    movl %esp, %ebp
    movl %ebp, %ecx
    addl $8, %ecx
    pushl %ecx
    pushl (%ebp)
    call set_argc_argv
    movl %ebp, %esp
    movl %edx, %ebp

    /* INFO(Rafael): Branching to --version or --help sections if the user asked us. */

    pushl $1
    pushl $0
    pushl $option_version
    call get_option
    addl $12, %esp

    cmp $1, %eax
    je show_version

    pushl $1
    pushl $0
    pushl $option_help
    call get_option
    addl $12, %esp

    cmp $1, %eax
    je show_help

    /* INFO(Rafael): Getting the --board-size=n option. */

    pushl $0
    pushl $default_board_size
    pushl $option_board_size
    call get_option
    addl $12, %esp

    pushl %eax

    pushl %eax
    call isnumber
    addl $4, %esp

    cmp $0, %eax
    je invalid_board_size

    popl %eax

    pushl %eax
    call atoi
    addl $4, %esp

    dec %eax
    cmp $1, %eax
    jnge invalid_board_size
    cmp $CELL_BYTES_PER_ROW, %eax
    jge invalid_board_size

    movl %eax, cell_row_max
    movl %eax, cell_col_max

    /* INFO(Rafael): Getting the --interactive option. */

    pushl $1
    pushl $0
    pushl $option_interactive
    call get_option
    addl $12, %esp
    movl %eax, interactive_mode

    /* INFO(Rafael): Getting the --generation-nr=n option. */

    pushl $0
    pushl $default_generation_nr
    pushl $option_generation_nr
    call get_option
    addl $12, %esp

    pushl %eax
    pushl %eax
    call isnumber
    addl $4, %esp

    cmp $0, %eax
    je invalid_generation_nr

    popl %eax

    pushl %eax
    call atoi
    addl $4, %esp

    movl %eax, generation_nr

    /* INFO(Rafael): Getting the --delay=millisecs option. */

    pushl $0
    pushl $default_delay
    pushl $option_delay
    call get_option
    addl $12, %esp

    pushl %eax

    pushl %eax
    call isnumber
    addl $4, %esp

    cmp $0, %eax
    je invalid_delay

    popl %eax

    pushl %eax
    call atoi
    addl $4, %esp

    cmp $0, %eax
    jle invalid_delay

    imul $1000, %eax
    movl %eax, usleep_time

    /* INFO(Rafael): Getting the --alive-color=color option. */

    pushl $0
    pushl default_alive_color
    pushl $option_alive_color
    call get_option
    addl $12, %esp

    pushl %eax
    pushl $alive_fmt
    call ldcolor
    addl $8, %esp

    cmp $0, %eax
    je invalid_alive_color

    /* INFO(Rafael): Getting the --dead-color=color option. */

    pushl $0
    pushl default_dead_color
    pushl $option_dead_color
    call get_option
    addl $12, %esp

    pushl %eax
    pushl $dead_fmt
    call ldcolor
    addl $8, %esp

    cmp $0, %eax
    je invalid_dead_color

    /* INFO(Rafael): Loading the initial generation defined by the user. */

    call ld1stgen
    call clrscr
    call life

    call clrscr
    pushl $sigint_watchdog_fmt
    call printf
    addl $4, %esp

    movl $0, %eax
    jmp bye

    show_version:
        pushl $version
        call printf
        addl $4, %esp
        movl $0, %eax
        jmp bye

    show_help:
        pushl 4(%esp)
        pushl $help
        call printf
        addl $4, %esp
        movl $0, %eax
        jmp bye

    invalid_board_size:
        pushl $err_invalid_board_size
        call printf
        addl $4, %esp
        movl $1, %eax
        jmp bye

    invalid_generation_nr:
        pushl $err_invalid_generation_nr
        call printf
        addl $4, %esp
        movl $1, %eax
        jmp bye

    invalid_delay:
        pushl $err_invalid_delay
        call printf
        addl $4, %esp
        movl $1, %eax
        jmp bye

    invalid_alive_color:
        pushl $err_invalid_alive_color
        call printf
        addl $4, %esp
        movl $1, %eax
        jmp bye

    invalid_dead_color:
        pushl $err_invalid_dead_color
        call printf
        addl $4, %esp
        movl $1, %eax
        jmp bye

    bye:
        pushl %eax
        call exit

.type sigint_watchdog, @function
sigint_watchdog: /* sigint_watchdog(int signo) */
    pushl %ebp
    movl %esp, %ebp

    movl $1, quit_game

    movl %ebp, %esp
    popl %ebp
ret

.type set_argc_argv, @function
set_argc_argv: /* set_argc_argv(argc, argv) */
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax
    movl %eax, argc
    movl 12(%ebp), %eax
    movl %eax, argv

    movl %ebp, %esp
    popl %ebp
ret

.type get_option, @function
get_option: /* get_option(option, default, is_boolean) */

    /* INFO(Rafael): Get the option loading it into EAX, if it does not exist load the default value from the stack  (C Style)*/

    pushl %ebp
    movl %esp, %ebp

    cmp $1, argc
    je get_option_default

    movl 8(%ebp), %edi
    pushl %edi
    movl $0xffff, %ecx
    movb $0, %al
    cld
    repne scasb
    popl %edi

    subw $0xfffe, %cx
    neg %cx

    movl argv, %edx

    get_option_parse_args:
        pushl %edi
        pushl %ecx

        movl (%edx), %esi

        repe cmpsb

        popl %ecx
        popl %edi

        jne get_option_parse_args_go_next

        cmp $1, 16(%ebp)

        je get_option_parse_args_set_boolean

        movl %esi, %eax
        jmp get_option_epilogue

        get_option_parse_args_set_boolean:
            movl $1, %eax
            jmp get_option_epilogue

        get_option_parse_args_go_next:
            addl $4, %edx

        cmp $0, (%edx)
    jne get_option_parse_args

    get_option_default:
        movl 12(%ebp), %eax

    get_option_epilogue:
        movl %ebp, %esp
        popl %ebp
ret

.type ld1stgen, @function
ld1stgen: /* ld1stgen() */
    pushl %ebp
    movl %esp, %ebp

    xorl %ecx, %ecx

    ld1stgen_rloop:

        xorl %edi, %edi
        movl %ecx, %ebx
        imul $CELL_BYTES_PER_ROW, %ebx

        ld1stgen_cloop:

            pushl %ebx
            pushl %ecx
            pushl %edi

            pushl %edi
            pushl %ecx
            pushl $option_cell_fmt
            pushl $temp_str
            call sprintf
            addl $16, %esp

            pushl $1
            pushl $0
            pushl $temp_str
            call get_option
            addl $12, %esp

            popl %edi
            popl %ecx
            popl %ebx

            movb %al, cells(%ebx, %edi, 1)

            inc %edi
            cmp cell_col_max, %edi
        jle ld1stgen_cloop

        inc %ecx
        cmp cell_row_max, %ecx
    jle ld1stgen_rloop

    movl %ebp, %esp
    popl %ebp
ret

.type life, @function
life: /* life() */
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    xorl %eax, %eax
    xorl %ebx, %ebx

    movl $0, -8(%ebp)

    gameloop:
        cmp $1, quit_game
        je life_epilogue

        call genprint

        cmp $1, interactive_mode
        je gameloop_enter_waiting

        pushl usleep_time
        call usleep
        addl $4, %esp

        jmp gameloop_gonext

        gameloop_enter_waiting:
            leal -4(%ebp), %ecx
            pushl $1
            pushl %ecx
            pushl $0
            call read
            addl $12, %esp

        gameloop_gonext:
            call apply_rules

        cmp $0, generation_nr
        je gameloop

        leal -8(%ebp), %edx
        addl $1, (%edx)
        movl generation_nr, %ecx
        cmp (%edx), %ecx
    jne gameloop

    life_epilogue:
        movl %ebp, %esp
        popl %ebp
ret

.type isnumber, @function
isnumber: /* isnumber(value) */
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %esi
    movl (%esi), %eax

    isnumber_parse:
        cmp $0x30, %al
        jl isnumber_parse_inval

        cmp $0x39, %al
        jg isnumber_parse_inval

        jmp isnumber_parse_inc

        isnumber_parse_inval:
            movl $0, %eax
            jmp isnumber_epilogue

        isnumber_parse_inc:
            inc %esi

        movl (%esi), %eax

        cmp $0x00, %al
    jne isnumber_parse

    movl $1, %eax

    isnumber_epilogue:
        movl %ebp, %esp
        popl %ebp
ret

.type ldcolor, @function
ldcolor: /* ldcolor(addr color_fmt, color) */

    /* INFO(Rafael): This function loads the ansi color coding into the passed formatter.
                     Returning back 0 on loading errors otherwise 1. */

    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx

    ldcolor_parse:
        pushl %ecx

        movl colors(, %ecx, 4), %edi
        pushl %edi
        movl $0xffff, %ecx
        movb $0, %al
        cld
        repne scasb
        subw $0xfffe, %cx
        neg %cx

        movl 12(%ebp), %esi
        popl %edi

        repe cmpsb
        jne ldcolor_parse_inc

        popl %ecx
        movl 8(%ebp), %edi
        addl $3, %edi
        addl %ecx, (%edi)

        movl $1, %eax

        jmp ldcolor_epilogue

        ldcolor_parse_inc:
            popl %ecx
            inc %ecx

        cmp colors_nr, %ecx
    jne ldcolor_parse

    movl $0, %eax

    ldcolor_epilogue:
        movl %ebp, %esp
        popl %ebp
ret

.type clrscr, @function
clrscr: /* clrscr() */
    pushl %ebp
    movl %esp, %ebp

    pushl $clrscr_fmt
    call printf
    addl $4, %esp

    movl $1, %eax
    movl $2, %ebx

    call gotoxy

    movl %ebp, %esp
    popl %ebp
ret

.type gotoxy, @function
gotoxy: /* gotoxy(EAX, EBX) */
    pushl %ebp
    movl %esp, %ebp

    pushl %eax
    pushl %ebx
    pushl $gotoxy_fmt
    call printf
    addl $12, %esp

    movl %ebp, %esp
    popl %ebp
ret

.type genprint, @function
genprint: /* genprint() */
    /*
     * INFO(Rafael): Well, it prints one generation.
     *
     * During its execution...
     *
     * EAX and EBX store the x, y coordinates used on gotoxy() calls
     * ECX holds the base offset of "cells" (a.k.a row index -> cells[y][]...)
     * EDI holds the col index of "cells" cells[][x]...
     * EDX holds the current byte stored in cell[][x]...
     *
     */
    pushl %ebp
    movl %esp, %ebp

    pushl %ecx

    xorl %ecx, %ecx
    movl $2, %ebx

    rloop:
        xorl %edi, %edi
        movl $CELL_ROW_INITIAL_X, %eax

        cloop:
            pushl %eax

            movl %ecx, %eax
            imul $CELL_BYTES_PER_ROW, %eax

            movl cells(%eax, %edi, 1), %edx

            popl %eax

            pushl %eax
            pushl %ebx
            pushl %ecx
            pushl %edx
            pushl %edi

            cmp $1, %dl
            je push_alive

            pushl $dead_fmt
            jmp cellprint

            push_alive:
                pushl $alive_fmt

            cellprint:
                call gotoxy

            call printf
            addl $4, %esp

            popl %edi
            popl %edx
            popl %ecx
            popl %ebx
            popl %eax

            inc %edi
            inc %eax
            cmp cell_col_max, %edi
        jle cloop

        pushl %eax
        pushl %ebx
        pushl %ecx
        pushl %edx
        pushl %edi

        pushl $newline_fmt
        call printf
        addl $4, %esp

        popl %edi
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax

        inc %ecx
        inc %ebx

        cmp cell_row_max, %ecx
    jle rloop

    popl %ecx

    movl %ebp, %esp
    popl %ebp
ret

.type apply_rules, @function
apply_rules: /* apply_rules(EAX, EBX) */
    /*
     * INFO(Rafael): If life sucks to you, I think that you should start from here ;)
     */
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ebx
    pushl %edx

    /* INFO(Rafael): Basically it traverses the cells inspecting the neighbours of each one and then applies
                     the game rules.

                     I think that use a kind of "temp_cells", "aux_cells" only to store the next generation data
                     is quite useless and a waste of memory, due to it I have chosen to store the next generation
                     data in the most significant nibble from the "cells", it still sucks but less.

                     So, the first (row;col) iteration generates a kind of "alternative world"... the second one
                     takes Alice (without Bob and Eva but with us) there by right shifting our current "brana"
                     4 bits. ;) */

    xorl %eax, %eax

    apply_rules_rloop.0:

        xorl %ebx, %ebx

        apply_rules_cloop.0:

            call inspect_neighbourhood

            pushl %eax
            imul $CELL_BYTES_PER_ROW, %eax

            pushl %ecx
            movl cells(%eax, %ebx, 1), %ecx

            cmp $1, %cl
            jne deadcell_rules

            livecell_rules:

                cmp $2, alive_cell_nr

                jl underpopulation

                je next_generation

                cmp $3, alive_cell_nr

                je next_generation

                jg overpopulation

                /* RULE(1): Any live cell with fewer than two live neighbours dies, as if caused by underpopulation. */
                underpopulation:
                    /* INFO(Rafael): The next generation nibble is already zero, thus just skipping to increment stuff. */
                    jmp apply_rules_cloop_inc

                /* RULE(2): Any live cell with two or three live neighbours lives on to the next generation. */
                next_generation:
                    jmp reproduction

                /* RULE(3): Any live cell with more than three live neighbours dies, as if by overpopulation. */
                overpopulation:
                    /* INFO(Rafael): The next generation nibble is already '0', thus just skip to increment stuff. */
                    jmp apply_rules_cloop_inc

            deadcell_rules:
                cmp $3, alive_cell_nr
                jne apply_rules_cloop_inc

                /* RULE(4): Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction. */
                reproduction:
                    xorb $0x10, %cl

            apply_rules_cloop_inc:
                /* INFO(Rafael): Nice, now we got the present and future of this cell at the same "byte". */
                movb %cl, cells(%eax, %ebx, 1)
                inc %ebx

            popl %ecx
            popl %eax

            cmp cell_col_max, %ebx
        jle apply_rules_cloop.0

        inc %eax
        cmp cell_row_max, %eax
    jle apply_rules_rloop.0

    xorl %eax, %eax
    xorl %edx, %edx

    /* INFO(Rafael): The lair of the rabbit... */

    apply_rules_rloop.1:
        xorl %ebx, %ebx
        pushl %eax
        imul $CELL_BYTES_PER_ROW, %eax
        apply_rules_cloop.1:
            shrb $4, cells(%eax, %ebx, 1) /* now step out kids, it will shift space and time... */
            inc %ebx
            cmp cell_col_max, %ebx
        jle apply_rules_cloop.1
        popl %eax
        inc %eax
        cmp cell_row_max, %eax
    jle apply_rules_rloop.1

    popl %edx
    popl %ebx
    popl %eax
    movl %ebp, %esp
    popl %ebp
ret

.type inspect_neighbourhood, @function
inspect_neighbourhood: /* inspect_neighbourhood(EAX, EBX) */
    /*
     * INFO(Rafael): Given a "high level" coordinate [ E.g.: cells(1;1) ]...
     *
     * ...this function will inspect the neighbours of the related cell, getting the amount of
     * alive cells. When calling this function, the EAX register must hold the "y" and the EBX the "x".
     *
     *                                           T T T
     * This game defines your neighbourhood as:  T U T
     *                                           T T T
     *
     * Maybe this function could be improved to evalute only the enough to take some decision instead
     * of visiting and counting all neighbours. By now it is okay.
     */

    pushl %ebp
    movl %esp, %ebp
    pushl %eax

    movl %ebx, %edi

    movl $0, alive_cell_nr

    /* INFO(Rafael): Inspecting the state of cells[r+1][c]. */

    pushl %eax
    pushl %edi

    cmp cell_row_max, %eax
    je rule_r1c_end

    inc %eax
    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r1c_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r1c_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r-1][c]. */

    pushl %eax
    pushl %edi

    cmp cell_row_min, %eax
    je rule_r_1c_end

    dec %eax

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r_1c_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r_1c_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r][c+1]. */

    pushl %eax
    pushl %edi

    cmp cell_col_max, %edi
    je rule_r_c1_end

    inc %edi

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r_c1_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r_c1_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r][c-1]. */

    pushl %eax
    pushl %edi

    cmp cell_col_min, %edi
    je rule_r_c_1_end

    dec %edi

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r_c_1_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r_c_1_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r-1][c-1]. */

    pushl %eax
    pushl %edi

    cmp cell_row_min, %eax
    je rule_r_1_c_1_end

    cmp cell_col_min, %edi
    je rule_r_1_c_1_end

    dec %eax
    dec %edi

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r_1_c_1_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r_1_c_1_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r-1][c+1]. */

    pushl %eax
    pushl %edi

    cmp cell_row_min, %eax
    je rule_r_1_c1_end

    cmp cell_col_max, %edi
    je rule_r_1_c1_end

    dec %eax
    inc %edi

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r_1_c1_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r_1_c1_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r+1][c-1]. */

    pushl %eax
    pushl %edi

    cmp cell_row_max, %eax
    je rule_r1_c_1_end

    cmp cell_col_min, %edi
    je rule_r1_c_1_end

    inc %eax
    dec %edi

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r1_c_1_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r1_c_1_end:
        popl %edi
        popl %eax

    /* INFO(Rafael): Inspecting the state of cells[r+1][c+1]. */

    pushl %eax
    pushl %edi

    cmp cell_row_max, %eax
    je rule_r1_c1_end

    cmp cell_col_max, %edi
    je rule_r1_c1_end

    inc %eax
    inc %edi

    imul $CELL_BYTES_PER_ROW, %eax

    movl cells(%eax, %edi, 1), %eax
    andb $1, %al

    cmp $1, %al
    jne rule_r1_c1_end

    movl alive_cell_nr, %eax
    inc %eax
    movl %eax, alive_cell_nr

    rule_r1_c1_end:
        popl %edi
        popl %eax

    popl %eax
    movl %ebp, %esp
    popl %ebp
ret
