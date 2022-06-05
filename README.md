# Logging OpenSSH secure copy

Monitoring OpenSSH secure copy on an old server involves:

* Local users who can run `scp` to transfer files.
* Remote users who can run `scp` on their systems to access files on the server.

In both cases a local `scp` command is - eventually - being executed on the server.

This means that it is possible to tweak the `scp` executable on the server to enable rudimentary logging.


## Limitations
User accounts must have write-access to their individual log-files.

File names are not guaranteed to be logged. The source and/or destination folders are logged though.

Far from perfect, but at least it is relatively simple...



## Installation
Download and install the wrapper script in place of the original executable:
```
server:~ $ curl -O https://raw.githubusercontent.com/tlk/scp-logger/main/scp-logger.sh
server:~ $ sudo mv /usr/bin/scp /usr/bin/scp.original
server:~ $ sudo mv scp-logger.sh /usr/bin/scp
server:~ $ sudo chown root:root /usr/bin/scp
server:~ $ sudo chmod +r,go-w,+x /usr/bin/scp
```

How to uninstall:
```
server:~ $ sudo mv /usr/bin/scp.original /usr/bin/scp
```



## Example

Secure copy commands initiated by a local user on the server:
```
server:~ $ scp myfile remote1:
server:~ $ scp myfile remote1:folder
server:~ $ scp remote2:otherfile .
server:~ $ scp remote2:otherfile Documents
server:~ $ cat /tmp/scp_uid_1000_local.log 
2022-07-07 07:00:00+00:00	SSH_CONNECTION=10.0.0.126 58959 10.0.0.10 22 	myfile remote1:
2022-07-07 07:00:00+00:00	SSH_CONNECTION=10.0.0.126 58959 10.0.0.10 22 	myfile remote1:folder
2022-07-07 07:00:00+00:00	SSH_CONNECTION=10.0.0.126 58959 10.0.0.10 22 	remote2:otherfile .
2022-07-07 07:00:00+00:00	SSH_CONNECTION=10.0.0.126 58959 10.0.0.10 22 	remote2:otherfile Documents
server:~ $ 
```

Secure copy commands initiated by a remote user from outside the server:
```
laptop:~ % scp Monday.txt server:
laptop:~ % scp Monday.txt server:folder
laptop:~ % scp server:myfile .
laptop:~ % scp server:myfile Documents
laptop:~ % scp -r notes server:
laptop:~ % scp -r -v notes server:
```

```
server:~ $ cat /tmp/scp_uid_1000_remote.log 
2022-07-07 07:00:01+00:00	SSH_CONNECTION=10.0.0.126 59322 10.0.0.10 22 	-t .
2022-07-07 07:00:01+00:00	SSH_CONNECTION=10.0.0.126 59323 10.0.0.10 22 	-t folder
2022-07-07 07:00:01+00:00	SSH_CONNECTION=10.0.0.126 59324 10.0.0.10 22 	-f myfile
2022-07-07 07:00:01+00:00	SSH_CONNECTION=10.0.0.126 59325 10.0.0.10 22 	-f myfile
2022-07-07 07:00:01+00:00	SSH_CONNECTION=10.0.0.126 59326 10.0.0.10 22 	-t .
2022-07-07 07:00:01+00:00	SSH_CONNECTION=10.0.0.126 59327 10.0.0.10 22 	-t .
server:~ $ 
```

Note that the logged command arguments may include either `-t` or `-f`:
* `-t` meaning data transfer **_to_** the server (initiated by a remote user from outside the server).
* `-f` meaning data transfer **_from_** the server (initiated by a remote user from outside the server).

See https://github.com/openssh/openssh-portable/blob/V_9_0_P1/scp.c#L571-L577


### Relative paths
A path that does not start with `/` is relative to the user home dir `$HOME`.

When a path is logged as `.` it translates into `$HOME/.` which is simply the same as `$HOME`.




## Acknowledgements
* https://askubuntu.com/a/660153/1039302
* https://askubuntu.com/a/660243/1039302
