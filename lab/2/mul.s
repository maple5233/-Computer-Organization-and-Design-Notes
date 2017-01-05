.data
pleaseInput:    .asciiz "Input two number: \n"
resultString:   .asciiz "result :\n"
errorString:    .asciiz "Error: Result cause a overflow.\n"
mask:           .word32 0x1             # 掩码，取最后1位

CONTROL:    .word32 0x10000
DATA:       .word32 0x10008

.text
main:
    lwu     $t5,  DATA($zero)           # t5加载DATA
    lwu     $t6,  CONTROL($zero)        # t6加载控制器
    daddi   $v0,  $zero, 4              # v0 = 4                        
    daddi   $t0,  $zero, pleaseInput    # t0 = pleaseInput
    sw      $t0,  0($t5)                # 将t0塞进DATA
    sw      $v0,  0($t6)                # 将CONTROL设为4(v0)，输出pleaseInput
    daddi   $v0,  $zero, 8              # v0 = 8
    sw      $v0,  0($t6)                # 将CONTROL设为8(v0)，接受值
    lw      r19,  0($t5)                # r19 = 第一个数
    sw      $v0,  0($t6)                # 将CONTROL设为8(v0)，接受值
    lw      r20,  0($t5)                # r20 = 第二个数

    daddi   r21,  r21, 32               # n(r21) = 32
    daddi   r24,  r24, 0                # i(r24)  = 0
    daddi   r25,  r0,  1                # mask(r25) = 0x1

    daddi   r22,  r0,  0                # r22 存储结果 sum    初始化为 0
    daddi   r23,  r20, 0                # r23 存储临时量 temp 初始化为 second_num

step1:                                  # 检查乘数最低位并做出相应操作
    beq     r21,  r24, step3            # 循环判断：i == 32 时跳到step3 输出
    and     r23,  r23, r25              # 与掩码0x1做与运算 取最后一位
    beqz    r23,  step2                 # 判断得到的乘数最低位，为0跳到step2
    dadd    r22,  r22, r19              # 为1的话 乘积加上被乘数

step2:                                  # 被乘数左移1位，乘数右移1位
    dsll    r19,  r19, 1                # 被乘数左移1位
    dsra    r20,  r20, 1                # 乘数右移1位
    andi    r23,  r23, 0                # 临时变量清零
    daddi   r23,  r20, 0                # 赋值为乘数 
    daddi   r24,  r24, 1                # i++;
    j       step1                       # 下一次循环

step3:                                  # 输出结果
    daddi   $v0,  $zero, 4              # v0 = 4
    daddi   $t0,  $zero, resultString   # t0 = resultString
    sw      $t0,  0($t5)                # 将t0塞进DATA
    sw      $v0,  0($t6)                # 将CONTROL设为4(v0)，输出 resultString
    daddi   $v0,  $zero, 2              # v0 = 2 准备输出整型
    sw      r22,  0($t5)                # 把sum(r22)塞进DATA
    sw      $v0,  0($t6)                # 将CONTROL设为2(v0)，输出 sum
halt

