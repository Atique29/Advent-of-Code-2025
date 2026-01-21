import matplotlib.pyplot as plt

x = []
y = []

with open("input.txt") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        xi, yi = line.split(",")
        x.append(float(xi))
        y.append(float(yi))

# close the polygon
x.append(x[0])
y.append(y[0])

#Up
# x1 = [94564]*(x.__len__())
# y1 = [48699]*(y.__len__())
# x2 = [5267]*(x.__len__())
# y2 = [32241]*(y.__len__())
#Down
x1 = [94564]*(x.__len__())
y1 = [67626]*(y.__len__())
x2 = [5649]*(x.__len__())
y2 = [50077]*(y.__len__())

plt.figure()
plt.plot(x, y, linestyle='-')
plt.plot(x1, y, linestyle='--')
plt.plot(x, y1, linestyle=':')
plt.plot(x, y2, linestyle=':')
plt.plot(x2, y, linestyle='--')

# draw arrows for each edge
for i in range(len(x) - 1):
    dx = x[i+1] - x[i]
    dy = y[i+1] - y[i]
    plt.arrow(
        x[i], y[i], dx, dy,
        length_includes_head=True,
        head_width=0.05,
        head_length=0.1
    )

plt.xlabel("x")
plt.ylabel("y")
plt.axis("equal")
plt.grid(True)
plt.gca().invert_yaxis()
plt.show()

