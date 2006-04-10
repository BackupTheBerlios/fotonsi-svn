
def run():

    import re, os, sys

    try:
        import MCWidgets
    except ImportError:
        os.environ['PYTHONPATH'] = '../..'  # only for the tests

    r = re.compile(r'^t_.*\.py$', re.I)
    for fname in os.listdir('.'):
        if r.match(fname):
            print 'Running', fname
            pid = os.fork()
            if pid == 0:
                os.execv(sys.executable, ('python', fname))
            pid, result, = os.waitpid(pid, 0)
            if result != 0:
                print fname, 'exits with error code', result

if __name__ == '__main__':
    run()
