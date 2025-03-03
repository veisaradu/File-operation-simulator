.data
vector: .space 1024
copie: .space 1024
operatii: .space 4
index: .space 4
op: .long 0
nr_op: .long 0
descriptor: .long 0
dimensiune: .long 0
blocuri: .long 0
counter: .long 0
start: .long 0
end: .long 0
current_descriptor: .long 0
index2: .long 0
index3: .long 0
index4: .long 0
index5: .long 0
interval_start: .long 0
anterior: .long 0
c: .long 0
d: .long 0
formatScanf: .asciz "%d"
zero: .long 0
another: .long 0
formatPrintfAdd: .asciz "%d: (%d, %d)\n"
formatPrintfGet: .asciz "(%d, %d)\n"
formatPrintfMem: .asciz "%u \n"
formatNoSpace: .asciz "%d: (%d, %d)\n"
.text
.global main
main:


movl $0, %eax        
movl $0, %ecx      


initialize_vector:
cmp $1024, %ecx  
jge initialize_copie_p
lea vector, %edi
movb %al, (%edi, %ecx, 1)
incl %ecx        
jmp initialize_vector


initialize_copie_p:
movl $0, %eax        
movl $0, %ecx


initialize_copie:
cmp $1024, %ecx  
jge initialize_done
lea copie, %esi
movb %al, (%esi, %ecx, 1)
incl %ecx        
jmp initialize_copie


initialize_done:
pushl $operatii
pushl $formatScanf
call scanf
popl %ebx
popl %ebx


movl $0, index


et_for_op:
movl index, %ecx
cmp %ecx, operatii
je et_exit


pushl $op
pushl $formatScanf
call scanf
popl %ebx
popl %ebx


et_verificare_operatie:
xor %ebx,%ebx
movl op,%ebx
cmpl $1, %ebx
je read_num
cmpl $2, %ebx
je get_operation
cmpl $3,%ebx
je op_delete
cmpl $4,%ebx
je op_defrag




read_num:
movl $0,index2
pushl $nr_op
pushl $formatScanf
call scanf
popl %ebx
popl %ebx
jmp op_add






op_add:
movl index2, %ecx
cmp %ecx, nr_op
je et_cont_op


pushl $descriptor
pushl $formatScanf
call scanf
pop %ebx
pop %ebx


pushl $dimensiune
pushl $formatScanf
call scanf
pop %ebx
pop %ebx

movl dimensiune,%eax
movl $8,%ebx
xor %edx,%edx
divl %ebx


cmp $0,%edx
je no_inc
incl %eax


no_inc:
movl %eax,blocuri


find_space:
movl $0, %eax  
movl $0, counter  
movl $0, start
movl $0, index3
movl $0, end
xor %ecx,%ecx


check_space:
movl index3,%eax
cmp $1024,%eax
jge no_space_add


lea vector, %edi  
movb (%edi,%eax,1), %bl
cmpb $0, %bl
jne reset_counter


movl counter, %ecx
incl %ecx
movl %ecx, counter


cmpl blocuri, %ecx
jne continue_search




subl blocuri, %eax    
incl %eax
movl %eax, start
addl blocuri, %eax
decl %eax
movl %eax, end
jmp allocate_blocks


reset_counter:
movl $0, counter


continue_search:
incl index3
jmp check_space


no_space_add:
pushl $0
pushl $0
pushl descriptor
pushl $formatNoSpace
call printf
pop %ebx
incl index2
jmp op_add




allocate_blocks:
movl start, %eax
alloc_loop:
cmpl end, %eax
jg finish_add
movb descriptor,%dl
movb %dl, (%edi,%eax,1)
incl %eax
jmp alloc_loop


finish_add:
pushl end
pushl start
pushl descriptor
pushl $formatPrintfAdd
call printf
pop %ebx
pop %ebx
pop %ebx
pop %ebx
pushl $0
call fflush
popl %ebx
incl index2
jmp op_add


get_operation:
pushl $descriptor  
pushl $formatScanf
call scanf
popl %ebx
popl %ebx


movl $0, index3
movl $0, start
movl $-1, end
movl $0, %eax
movb descriptor, %dl


find_descriptor_blocks:
movl index3, %eax
cmp $1024, %eax
jge no_match_get


lea vector, %edi
movb (%edi, %eax, 1), %bl
cmpb %dl, %bl
jne continue_search_get


xor %ebx,%ebx
movl end,%ebx
cmp $-1, %ebx
je start_new_interval_get
movl %eax, end
jmp continue_search_get


start_new_interval_get:
movl %eax, start
movl %eax, end




continue_search_get:
incl index3
jmp find_descriptor_blocks


no_match_get:
xor %ebx,%ebx
movl end,%ebx
cmp $-1, %ebx
je print_no_match
pushl end              
pushl start
pushl $formatPrintfGet
call printf
popl %ebx
popl %ebx
popl %ebx
pushl $0
call fflush
popl %ebx
jmp et_cont_op


print_no_match:
pushl $0            
pushl $0              
pushl $formatPrintfGet  
call printf  
popl %ebx
popl %ebx
popl %ebx
pushl $0
call fflush
popl %ebx
jmp et_cont_op


op_delete:
pushl $descriptor
pushl $formatScanf
call scanf
popl %ebx
popl %ebx


movl $0, index3        
movb descriptor, %dl


clear_blocks_loop:
movl index3, %ecx
cmp $1024, %ecx    
jge clear_blocks_done

lea vector, %edi        
movb (%edi, %ecx, 1), %bl
cmpb descriptor, %bl        
jne skip_clear
movb $0, (%edi, %ecx, 1)


skip_clear:
incl index3        
jmp clear_blocks_loop


clear_blocks_done:
movl $0,anterior
movl $0, index4
movl $-1, start
lea vector, %edi
movb $0, current_descriptor


check_loop_start:
movl index4, %ecx
cmp $1024, %ecx
jge last
lea vector, %edi
movb (%edi, %ecx, 1), %dl
cmpb $0, %dl
je skip_to_next_element
cmpb %dl, current_descriptor
jne handle_new_descriptor
incl index4
jmp check_loop_start

last:
movl $1023,%ecx
movb (%edi,%ecx,1),%dl
cmp $0,%dl
jne print_last
jmp et_cont_op

print_last:
pushl $1023
pushl start
pushl current_descriptor
pushl $formatPrintfAdd
call printf
popl %ebx
popl %ebx
popl %ebx
popl %ebx
jmp et_cont_op

handle_new_descriptor:
movl $-1, %ebx
cmp start, %ebx
je set_new_start


cv:
movb %dl, c
movb current_descriptor,%al
cmp $0,%al
je alt
movl index4, %ebx
decl %ebx
pushl %ebx
pushl start
pushl current_descriptor
pushl $formatPrintfAdd
call printf
popl %ebx
popl %ebx
popl %ebx
popl %ebx


alt:
movb c,%dl
movb %dl,current_descriptor
movl $-1,%ebx
movl %ebx, start
cmp $0,%dl
je sarit_peste
movl $0,anterior
jmp set_new_start


sarit_peste:
movl $-1,%eax
movl %eax,anterior
incl index4
jmp check_loop_start


special:
incl index4
jmp check_loop_start


set_new_start:
movl index4,%ebx
movl %ebx, start
movb %dl, current_descriptor
incl index4
jmp check_loop_start




skip_to_next_element:
movb zero,%al
cmpb $1,%al
je salt


movb current_descriptor,%bl
cmp %bl,%dl
je special


movb current_descriptor,%bl
cmp $0,%bl
jne cv
movb $1,zero


salt:
incl index4
jmp check_loop_start


op_defrag:
movl $0, index3        
movl $0, index4        
lea vector, %edi
lea copie, %esi  


copy_non_zero:
movl index3, %ecx
cmp $1024, %ecx  
jge copy_back_to_vector


movb (%edi, %ecx, 1), %al
cmpb $0, %al
je skip_non_zero_copy


movl index4, %edx
cmp $1024, %edx
jge copy_back_to_vector


movb %al, (%esi, %edx, 1)
incl index4  


skip_non_zero_copy:
incl index3
jmp copy_non_zero


copy_back_to_vector:
movl $0, index3


copy_from_copie:
movl index3, %ecx  
cmp $1024, %ecx    
jge start_print_intervals


movb (%esi, %ecx, 1), %al
movb %al, (%edi, %ecx, 1)
incl index3      
jmp copy_from_copie  





start_print_intervals:
movl $0, index4              
movl $-1, current_descriptor    
movl $-1, start
movl $0,end        
xor %ecx,%ecx

prep_copie_next:
cmp $1024, %ecx  
jge interm
lea copie, %esi
movb $0, (%esi, %ecx, 1)
incl %ecx        
jmp prep_copie_next

interm:
xor %ecx,%ecx      



print_intervals:
movl index4, %ecx            
cmp $1024, %ecx      
jge last 


cmp $0,%ecx
je first_in_vector


return:
movb (%edi, %ecx, 1), %al


cmp $0,%al
je print_final


cmp current_descriptor,%al
jne print




incl index4        
jmp print_intervals    




first_in_vector:
movb (%edi, %ecx, 1), %al
movl %ecx,start
movb %al,current_descriptor
cmp $0,%al
je et_cont_op
incl index4
jmp print_intervals






print:
xor %eax,%eax
movl index4,%eax
decl %eax
movl %eax,end
movzb (%edi, %eax, 1),%eax
movl %eax,current_descriptor


pushl end
pushl start
pushl current_descriptor                  
pushl $formatPrintfAdd        
call printf                
popl %ebx
popl %ebx
popl %ebx
popl %ebx
push $0
call fflush
popl %ebx


movl index4,%edx
movl %edx,start
movb (%edi,%edx,1),%al
movb %al,current_descriptor

incl index4
jmp print_intervals








print_final:
xor %eax,%eax
movl index4,%eax
decl %eax
movl %eax,end
movzb (%edi, %eax, 1),%eax
movl %eax,current_descriptor


pushl end
pushl start
pushl current_descriptor                  
pushl $formatPrintfAdd        
call printf                
popl %ebx
popl %ebx
popl %ebx
popl %ebx
push $0
call fflush
popl %ebx


movl $1024,%ebx
movl %ebx,index4
jmp print_intervals


end_defrag:
jmp et_cont_op  


et_cont_op:
incl index
jmp et_for_op


et_exit:
pushl $0
call fflush
popl %eax

movl $1, %eax
xorl %ebx, %ebx
int $0x80
