# fava-docker

A Dockerfile for beancount-fava

## Environment Variable

- `BEANCOUNT_FILE`: path to your beancount file. Default to empty string.

## Usage Example

assume you have example.beancount in the current directory:

```shell
docker run -p 5000:5000 -v $PWD:/bean -e BEANCOUNT_FILE=/bean/example.beancount muyinliu/fava-docker
```
