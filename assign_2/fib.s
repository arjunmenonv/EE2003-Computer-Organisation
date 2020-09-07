#   RISC V Assembly Program to Compute Fibonacci Series term corresponding to index N 
#                                          (N < 48, as registers are only 32 bit long)
#   ISA: RV32I 
#   Author: Arjun Menon Vadakkeveedu (EE18B104)
#   Assignment 2, EE2003 Computer Organisation, Fall 2020

.global fib

fib:
      addi a1, a0, 0   # mv a0 (N) to a1
      li a2, 1         # if a1 == 1, return call
      li a0, 1         # fib(1) = 1
      li t0, 0         # t0 stores previous sum, fib(0) = 0 by convention
      blt a1, a2, invalid_idx   # if N is less than 1, return with error message
LOOP:  
      mv t1, t0     # t1 is a temp reg used only for swap
      mv t0, a0
      mv a0, t1     # swap a0 and t0 so that a0 now stores prev sum (to be overwritten) and t0 current sum
      add a0, a0, t0
      addi a1, a1, -1
      bltu a0, t0, reg_overflow   # since all register values are unsigned, if a0 (= a0 + t0) < t0, Overflow must have occurred
      blt a2, a1, LOOP
ret_call:
      jr ra
# Exceptions (overflow and invalid index)      
invalid_idx:
     li a0, 1
     la a1, idx_error
     li a2, 22
     li a7, 64    # linux write system call
     ecall
     j ret_call
reg_overflow:
     li a0, 1
     la a1, overflow_error
     li a2, 20
     li a7, 64    # linux write system call
     ecall
     j ret_call
idx_error:
     .ascii "Invalid index N (< 1)\n"
overflow_error:
     .ascii "a0 Overflow (> 32b)\n"           

