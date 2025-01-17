# Setup example
Replace "pass" with your password.
```
export NOVNC_PASSWORD=pass
docker build --secret id=noVNC_password,env=NOVNC_PASSWORD -t orangedocker:latest . 
```

```
docker run --init -d --rm -p 6080:6080 orangedocker
```

Navigate to `https://localhost:6080/vnc.html` or `https://{host_ip}:6080/vnc.html` if on the same network. Certificates for SSL/TLS encryption are currently self-signed which means the browser will not allow connections by default without you clicking through and accepting the warning pop-up.

Once on the noVNC homepage click connect and input your password. On the left are also some useful settings such as "Local Scaling" to make the screen fit your browser.
