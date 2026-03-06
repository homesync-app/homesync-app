import base64
import hashlib

def get_hashes(pem_content):
    lines = pem_content.strip().split('\n')
    base64_data = ''.join(lines[1:-1])
    cert_bytes = base64.b64decode(base64_data)
    
    sha1 = hashlib.sha1(cert_bytes).hexdigest()
    sha256 = hashlib.sha256(cert_bytes).hexdigest()
    
    return sha1, sha256

# Debug Cert
pem_debug = """-----BEGIN CERTIFICATE-----
ZWJ1ZzEQMA4GA1UECgwHQW5kcm9pZDELMAkGA1UEBhMCVVMwIBcNMjYwMjI2MjIw
NzE3WhgPMjA1NjAyMTkyMjA3MTdaMDcxFjAUBgNVBAMMDUFuZHJvaWQgRGVidWcx
EDAOBgNVBAoMB0FuZHJvaWQxCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA18AlVNieABARr0EAtF+u8gjE+uOX85Yq1RNVB5XhUJNW
eWmBlcobBwkZaGmwoPMCDwO5j5IpX86ZuxiaFsx5v1iA+y8olTSeFqqNM2ilJSPG
u/GmFYKTqR23AjaFxu6OSVlZ6UETpEcn0wqq6Kii26lfjZnLwfiqyGt84fuuz/3J
FAiN7CYNLNU2wHhxXs3To87Xvmx3UiABFduQ5nOyeA+Jb9Kzxb3YK9oPsSz0j3uK
yJ/8nJD9wUiqvBSkKWqjvD9Vkpn6GOB0ZRgIkpZZp+zTxLDBVteNcyUUiXsH3twC
3ay6tsrGqclFTxLU8RlOoa7hhp1eyPfQ4EZiRonO9QIDAQABMA0GCSqGSIb3DQEB
CwUAA4IBAQDTIFaqDIAMQolmkvkbzg9vpmleozoSE4O2NBlfo0tEq0ErDLGKbzrO
vx03Ljh6ci2nLLpbuFv1hvmqo38YRNLOD7cZY5frVRjDhdXCxzcIVmv42MN54SHs
2+iX8l9pODVby51rGTXV8IcQauRqj5/LCuvDPtvC8OkmNBc8SG9ouckcFnKZKr7v
ZWWKBDuSjzk6j+uF6WASZXJb0YVBE792H/T2Wdj2aaZawt5asS72+Xl26vf06VJW
MpR1UpmjBT21ykwhu4Mhd/+xA1oHtzQUQgmvLC29B8zQc4O1k3xCVgxXPeDxU9U1
I4XXAwYcZB9P/exLgfWb0hSp6YlTF5iN
-----END CERTIFICATE-----"""

sha1, sha256 = get_hashes(pem_debug)
print(f"DEBUG SHA1: {sha1}")
print(f"DEBUG SHA256: {sha256}")
