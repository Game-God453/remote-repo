def GreatestCommonfactor(a, b):  # 求a和b的最大公因数(a,b)
    if abs(a) < abs(b):
        a, b = b, a
    sym_a=1
    sym_b=1
    if a<0:
        a=-a
        sym_a=-1
    if b<0:
        b=-b
        sym_b=-1
    r = [a, b]
    q = ["skip", "skip"]  # q[2]=实际的q0
    i = 2
    while r[-1] != 0:
        q.append(r[i - 2] // r[i - 1])
        r.append(r[i - 2] % r[i - 1])
        i += 1
    print(f"({a*sym_a},{b*sym_b})={r[-2]}")


def GreatestCommonFactors_display(a, b):
    if abs(a) < abs(b):
        a, b = b, a
    sym_a=1
    sym_b=1
    if a<0:
        a=-a
        sym_a=-1
    if b<0:
        b=-b
        sym_b=-1
    r = [a, b]  # r[0]=实际的r(-2),r[1]=实际的r(-1)，r[2]=实际的r0
    q = ["skip", "skip"]  # q[2]=实际的q0
    i = 2
    print("计算过程如下：")
    while r[-1] != 0:
        q.append(r[i - 2] // r[i - 1])
        r.append(r[i - 2] % r[i - 1])
        print(f"{r[i - 2]}={q[i]}×{r[i - 1]}+{r[-1]}")
        i += 1
    print(f"则({a*sym_a},{b*sym_b})={r[-2]}")


def Bezout(a, b):  # 求满足s×a+t×b=(a,b)的s和t
    if abs(a) < abs(b):
        a, b = b, a
    sym_a=1
    sym_b=1
    if a<0:
        a=-a
        sym_a=-1
    if b<0:
        b=-b
        sym_b=-1
    q=[]
    r=[]
    def GreatestCommonfactor(a, b):
        r = [a, b]
        q = ["skip", "skip"]  # q[2]=实际的q0
        i = 2
        while r[-1] != 0:
            q.append(r[i - 2] // r[i - 1])
            r.append(r[i - 2] % r[i - 1])
            i += 1
        return q,r
    q,r=GreatestCommonfactor(a,b)
    n=len(r)
    t=[-q[n-2]]
    s=[1]
    for i in range(1,n-2-1):
        s.append(t[-1])
        t.append(t[-1]*((-1)*q[n-2-i])+s[-2])
    print(f"s={s[-1]*sym_a},t={t[-1]*sym_b}(注意：s对应的是绝对值更大的那个数)")


def Bezout_display(a, b):
    if abs(a) < abs(b):
        a, b = b, a
    sym_a=1
    sym_b=1
    if a<0:
        a=-a
        sym_a=-1
    if b<0:
        b=-b
        sym_b=-1
    q=[]
    r=[]
    def GreatestCommonFactors_display(a, b):
        r = [a, b]  # r[0]=实际的r(-2),r[1]=实际的r(-1)，r[2]=实际的r0
        q = ["skip", "skip"]  # q[2]=实际的q0
        i = 2
        print(f"先求({a},{b})：")
        while r[-1] != 0:
            q.append(r[i - 2] // r[i - 1])
            r.append(r[i - 2] % r[i - 1])
            print(f"{r[i - 2]}={q[i]}×{r[i - 1]}+{r[-1]}")
            i += 1
        print(f"则({a},{b})={r[-2]}")
        return q,r,r[-2]

    q, r ,x = GreatestCommonFactors_display(a, b)
    n = len(r)
    t = [-q[n - 2]]
    s = [1]
    print(f"{x} = ({t[0]})•{r[n-2-1]} + {r[n-2-2]}")
    for i in range(1, n - 2 - 1):
        temp=(-1) * q[n - 2 - i]
        print(f"    = {'(' if t[-1]<0 else ''}{t[-1]}{')' if t[-1]<0 else ''}"
              f"•({'(' if temp<0 else ''}{temp}{')' if temp<0 else ''}•{r[n-2-(i+1)]}+{r[n-2-(i+2)]})"
              f" + {'(' if i>1 and t[-2]<0 else ''}{1 if i==1 else t[-2]}{')' if i>1 and t[-2]<0 else ''}•{r[n-2-(i+1)]}")
        s.append(t[-1])
        t.append(t[-1] * temp + s[-2])
    print(f"    = {'(' if s[-1]*sym_a<0 else ''}{s[-1]*sym_a}{')' if s[-1]*sym_a<0 else ''}"
          f"•{'(' if a*sym_a<0 else ''}{a*sym_a}{')' if a*sym_a<0 else ''}"
          f" + {'(' if t[-1]*sym_b<0 else ''}{t[-1]*sym_b}{')' if t[-1]*sym_b<0 else ''}"
          f"•{'(' if b*sym_b<0 else ''}{b*sym_b}{')' if b*sym_b<0 else ''}")
    print(f"因此，整数s={s[-1] * sym_a}，t={t[-1] * sym_b}(注意：s对应的是绝对值更大的那个数)")


def MEbRS(num, exp, mod):         #模重复平方计算法
    binary = list(bin(exp))
    n = binary[2:]
    a_init = 1
    a = [a_init]
    b = [num]
    for i in range(0, len(n)):
        if n[-(i + 1)] == '1':
            a.append((a[i] * b[i]) % mod)
        else:
            a.append(a[i])
        b.append((b[i] * b[i]) % mod)
    print(a[-1])


def MEbRS_display(num, exp, mod):
    binary = list(bin(exp))
    n = binary[2:]
    a_init = 1
    a = [a_init]
    b = [num]
    print(f"解 设m={mod}，b={num}. 令a=1. 将{exp}写成二进制，")
    print(f"        {exp} = ", end='')
    for i in range(0, len(n)):
        if n[-(i + 1)] == '1':
            if i == 0:
                print("1", end='')
            else:
                print(f"2^{i}", end='')
            if i != len(n) - 1:
                print('+', end='')
    print("\n运用模重复平方法，依次计算如下：")
    for i in range(0, len(n)):
        print(f"({i}) n{i}={n[-(i + 1)]}. 计算")
        if n[-(i + 1)] == '1':
            a.append((a[i] * b[i]) % mod)
            if i == 0:
                print(f"        a{i}=a•b≡{a[-1]}" + "， ", end='')
            else:
                print(f"        a{i}=a{i - 1}•b{i}≡{a[-1]}" + "， ", end='')
        else:
            a.append(a[i])
            if i == 0:
                print(f"        a{i}=a≡{a[-1]}" + "， ", end='')
            else:
                print(f"        a{i}=a{i - 1}≡{a[-1]}" + "， ", end='')
        b.append((b[i] * b[i]) % mod)
        if i == 0 and i <= len(n) - 1:
            print(f"b{i + 1}≡b^2≡{b[-1]}(mod {mod}).")
        else:
            print(f"b{i + 1}≡b{i}^2≡{b[-1]}(mod {mod}).")
    print("最后，计算出")
    print(f"        {num}^{exp}≡{a[-1]}(mod {mod}).")


if __name__ == '__main__':
    funtion=('1','2','3','4','5','6')
    print("目前可以计算的内容如下：")
    print("1:求最大公因数\n"
          "2:求最大公因数(展示求解过程)\n"
          "3:Bézout(贝祖)等式( 数学表达式为：s•a+t•b=(a,b) )\n"
          "4:Bézout(贝祖)等式(展示求解过程)\n"
          "5:模重复平方法\n"
          "6:模重复平方法(展示求解过程)\n")
    choise = input("请输入你想要计算的序号：")
    while choise in funtion:
        match choise:
            case '1':
                a,b=map(int,input("\n请输入两个数a,b: ").split(','))
                GreatestCommonfactor(a,b)
            case '2':
                a, b = map(int, input("\n请输入两个数a,b: ").split(','))
                GreatestCommonFactors_display(a, b)
            case '3':
                a, b = map(int, input("\n请输入两个数a,b: ").split(','))
                Bezout(a,b)
            case '4':
                a, b = map(int, input("\n请输入两个数a,b: ").split(','))
                Bezout_display(a, b)
            case '5':
                num,exp,mod = map(int,input("\n请输入底数，指数，模数：").split(','))
                MEbRS(num,exp,mod)
            case '6':
                num, exp, mod = map(int, input("\n请输入底数，指数，模数：").split(','))
                MEbRS_display(num, exp, mod)
        print("\n计算完成！\n")
        print("目前可以计算的内容如下：")
        print("1:求最大公因数\n"
              "2:求最大公因数(展示求解过程)\n"
              "3:Bézout(贝祖)等式( 数学表达式为：s•a+t•b=(a,b) )\n"
              "4:Bézout(贝祖)等式(展示求解过程)\n"
              "5:模重复平方法\n"
              "6:模重复平方法(展示求解过程)\n")
        choise = input("请继续输入你想要计算的序号(退出选择任意其它按键即可)：")


    print("再见，欢迎下次使用！")