Get let's encrypt certificates via gcloud dns OR any DNS provider via CNAME alias to gcloud dns

Source tool is [acme.sh](https://github.com/Neilpang/acme.sh)


## 1. Prepare Cloud DNS
- [Create service account & download json key](https://console.cloud.google.com/iam-admin/serviceaccounts)
- [Add service account as member & give it dns admin role](https://console.cloud.google.com/iam-admin/iam)

## 2. Deploy container:
```bash
# 1. Insert your gcloud service key
volume_path=/opt/docker/acme.sh
mkdir -p $volume_path; nano $volume_path/auth.json

# 2. Run container:
docker run -itd -v "$volume_path":/acme.sh --restart=always --net=host --name=acme.sh bytemux/acme.sh-gcloud daemon

# 3. Activate gcloud configuration
## Using local auth.json
docker exec -it acme.sh gcloud auth activate-service-account $(grep -Po '"client_email":\K[^,}]+' $volume_path/auth.json | tr -d \") --key-file=/acme.sh/auth.json --project=$(grep -Po '"project_id":\K[^,}]+' $volume_path/auth.json | tr -d \" | tr -d " ")
## Or by specifying project manually
docker exec -it acme.sh gcloud auth activate-service-account acme-sh@example.iam.gserviceaccount.com --key-file=/acme.sh/auth.json --project=example

# 4. Test issue, adjust --dnssleep 600 option according your dns provider slowness
docker exec acme.sh --issue --test --dnssleep 600 --dns dns_gcloud --domain-alias sub.aliasdomain.com -d *.sub.maindomain.com

```

## 3. Usage example: issue wildcard cert with alias on gcloud
[acme.sh dns alias](https://github.com/Neilpang/acme.sh/wiki/DNS-alias-mode)
### Using --domain-alias (my prefered default)
```bash
# 1. Create CNAME: _acme-challenge.sub > sub.aliasdomain.com. & wait until record is updated
dig -t any _acme-challenge.sub.maindomain.com
# 2. Test issue
docker exec acme.sh --issue --test --dns dns_gcloud --domain-alias sub.aliasdomain.com -d *.sub.maindomain.com
# 3. Prod issue
docker exec acme.sh --issue --dns dns_gcloud --domain-alias sub.aliasdomain.com -d *.sub.maindomain.com
```

### Using --challenge-alias (alternative)
```bash
# 1. Create CNAME: _acme-challenge.sub >  _acme-challenge.aliasdomain.com. & wait until record is updated
dig -t any _acme-challenge.sub.maindomain.com
# 2. Test issue
docker exec acme.sh --issue --test --dns dns_gcloud --challenge-alias aliasdomain.com -d *.sub.maindomain.com
# 3. Prod issue
docker exec acme.sh --issue --dns dns_gcloud --challenge-alias aliasdomain.com -d *.sub.maindomain.com
```
