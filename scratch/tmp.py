try:
    i_stack.append( i )
except NameError:
    i_stack = []
 
i = 0

try:
    i_stack.append( i )
except NameError:
    i_stack = []

i = 7

try:
    i_stack.append( i )
except NameError:
    i_stack = ()

i = 8

print i
print i_stack

try:
   i = i_stack.pop()
except IndexError:
   pass

print i
print i_stack

try:
   i = i_stack.pop()
except IndexError:
   pass

print i
print i_stack

try:
   i = i_stack.pop()
except IndexError:
   pass

print i
print i_stack

