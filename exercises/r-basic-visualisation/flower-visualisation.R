flowers <- read.delim(
  file = file.path("data", "flower.csv"),
  header = TRUE,
  stringsAsFactors = TRUE
)

expected_columns <- c(
  "treat", "nitrogen", "block", "height", "weight",
  "leafarea", "shootarea", "flowers"
)
stopifnot(identical(names(flowers), expected_columns), nrow(flowers) == 96L)

str(flowers)
summary(flowers)

my_x <- 1:10
my_y <- seq(from = 1, to = 19, by = 2)

par(mfrow = c(2, 2))
plot(my_x, my_y, type = "l", main = "Line")
plot(my_x, my_y, type = "b", main = "Points and line")
plot(my_x, my_y, type = "h", main = "Vertical lines")
plot(my_x, my_y, type = "s", main = "Step plot")

par(mfrow = c(2, 2))
plot(flowers$weight, main = "Plant weight", ylab = "Weight")
plot(
  flowers$weight,
  flowers$shootarea,
  xlab = "Weight",
  ylab = "Shoot area",
  main = "Weight and shoot area"
)

height_breaks <- seq(from = 0, to = 18, by = 1)
hist(
  flowers$height,
  breaks = height_breaks,
  probability = TRUE,
  main = "Petunia height",
  xlab = "Height"
)
lines(density(flowers$height), col = "steelblue", lwd = 2)
dotchart(flowers$height, main = "Plant heights", xlab = "Height")

flowers$nitrogen <- factor(
  flowers$nitrogen,
  levels = c("low", "medium", "high")
)

par(mfrow = c(1, 2))
boxplot(
  weight ~ nitrogen,
  data = flowers,
  ylab = "Weight (g)",
  xlab = "Nitrogen level",
  main = "Weight by nitrogen"
)
boxplot(
  weight ~ nitrogen * treat,
  data = flowers,
  ylab = "Weight (g)",
  xlab = "Nitrogen level and treatment",
  main = "Grouped weight",
  cex.axis = 0.7
)

if (requireNamespace("vioplot", quietly = TRUE)) {
  vioplot::vioplot(
    weight ~ nitrogen,
    data = flowers,
    ylab = "Weight (g)",
    xlab = "Nitrogen level",
    col = "lightblue"
  )
} else {
  message("Optional violin plot skipped: install the 'vioplot' package to enable it.")
}
