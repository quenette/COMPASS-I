# I can't take the credit for this, although I'd love to - original code from: 
# http://musingsbymats.wordpress.com/2011/12/24/currying-composition-and-a-monad-in-python/

import inspect
class mycallable:
    def __init__(self, fun, nargs=None):
        '''make a callable out of fun, record number of args'''
        if nargs == None:
            if isinstance(fun, mycallable): self.nargs = fun.nargs
            else: self.nargs = len(inspect.getargspec(fun).args)
        else: self.nargs = nargs
        self.fun = fun
    def __add__(self, fun):
        '''compose self and fun'''
        f = (mycallable(fun) if not isinstance(fun, mycallable) else fun)
        return mycallable(lambda *args: self(f(*args)), f.nargs)
    def __call__(self, *args):
        '''do the currying'''
        if len(args) == self.nargs: # straight call
            return self.fun(*args)
        if len(args) == 0: # f() == f when arity of f is not 0
            return self
        if len(args) < self.nargs: # too few args
            return mycallable(lambda *ars: self.fun(*(args + ars)),
                              self.nargs-len(args))
        if len(args) > self.nargs: # if l x,y:x+y defined as l x:(l y:x+y)
            rargs = args[self.nargs:]
            res = self.fun(*(args[:self.nargs]))
            return (res(*rargs) if isinstance(res, mycallable) else res)

f = mycallable(lambda x,y : x + y)
h = mycallable(lambda x: x**2)
print (h + f)(1)(2)

f = lambda x : (x + 2, 'f added 2 to %d' % x)
g = lambda x : (x**2,  'g raised %d to the power of 2' % x)
print f(2)
