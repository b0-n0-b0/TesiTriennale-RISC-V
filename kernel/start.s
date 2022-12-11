.global start
start:
  # set M Previous mode to Supervisor for mret
  csrr a0, mstatus
  li a1, 0x1800
  xori a1, a1, -1
  and a0, a0, a1
  li a1, 0x800
  or a0, a0, a1
  csrw mstatus, a0

  #set M Exception Program Counter to main
  # main() defined in main.c
  la a0, main
  csrw mepc, a0
debug_mepc:
  # disable paging
  li a0, 0x0
  csrw satp, a0

  # delegate all interrupts and exceptions to supervisor mode
  li a0, 0xffff
  csrw medeleg, a0
  csrw mideleg, a0
  csrr a0, sie
  ori a0, a0, 0x200
  ori a0, a0, 0x20
  ori a0, a0, 0x2
  csrw sie, a0

  # configure physical memory protection to access to all
  # physical Memory
  li a0, 0x3fffffffffffffULL
  csrw pmpaddr0, a0
  li a0, 0xf
  csrw pmpcfg0, a0

  debug:
  mret
