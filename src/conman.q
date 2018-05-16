/////////////
// PRIVATE //
/////////////

.conman.priv.connections:1!flip`handle`conn`callback`args!"is**"$\:()
.conman.priv.timeout:1000
.conman.priv.retryInterval:0D00:00:01

///
// Connection close handler
// @param h int Handle
.conman.priv.zpc:{[h]
  if[not null conn:(dict:.conman.priv.connections h)`conn;
    delete from`.conman.priv.connections where handle=h;
    .conman.reconnect[conn;;]. first@'dict`callback`args];
  }

///
// Retry connection - dummy x argument to build projection for protected evaluation
// @param conn symbol Connection string
// @param callback function Callback function
// @param args any Arguments to pass to callback function
.conman.priv.retry:{[conn;callback;args;x]
  .timer.in[` sv`.conman.reconnect,conn;.conman.priv.retryInterval;`.conman.reconnect;(conn;callback;args)];
  }

////////////
// PUBLIC //
////////////

///
// Utility function to repeatedly attempt to connect to a given process until successful
// @param conn symbol Connection string
// @param callback symbol Optional callback function
// @param args any Arguments to pass to callback function
.conman.reconnect:{[conn;callback;args]
  handle:@[hopen;(conn;.conman.priv.timeout);.conman.priv.retry[conn;callback;args;]];
  if[-6=type handle;
    upsert[`.conman.priv.connections;(handle;conn;enlist callback;enlist args)];

    if[not null callback;
      $[1=count args;@;.].(callback[handle];args)]];
  }

//////////
// INIT //
//////////

.dotz.append[`.z.pc;`.conman.priv.zpc]
