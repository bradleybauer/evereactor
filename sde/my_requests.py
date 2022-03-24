import grequests


class ParallelRequest:

    def __init__(self, urls):
        self.urls = urls

    def exception(self, request, exception):
        print("Problem: {}: {}".format(request.url, exception))

    def go(self):
        return grequests.map((grequests.get(u) for u in self.urls), exception_handler=self.exception, size=30)
