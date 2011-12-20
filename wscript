# This just wraps make. This project doesn't build on anything besides Lion
# anyway

from subprocess import call

out = 'wscript-build'

def configure(ctx):
  pass

def build(ctx):
  call(['make','watchdir'])

def shutdown():
  call(['rm','-rf','wscript-build'])
