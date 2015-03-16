import std.file;
import std.math;
import std.stdio;
import std.random;

class Node {
  double[] vector;

  this(size_t dim) {
    vector.length = dim;

    for(auto i = 0; i < vector.length; i++) {
      vector[i] = uniform(0.3, 0.7);
    }
  }

  void update(double[] input, double learningRate)
  in {
    assert(input != null);
    assert(input.length == vector.length);
  }
  body {
    for(auto i = 0; i < vector.length; i++) {
      vector[i] += learningRate * (input[i] - vector[i]);
    }
  }

  double distance(double[] input)
  in {
    assert(input != null);
    assert(input.length == vector.length);
  }
  out(dist) {
    assert(dist > 0);
    assert(dist != double.nan);
  }
  body {
    double d = 0.0;

    for(auto i = 0; i < vector.length; i++) {
      d += pow(vector[i] - input[i], 2.0);
    }

    return sqrt(d);
  }

}

class Som {
  size_t size;
  size_t dimension;

  size_t count, countMax;

  Node nodes[];

  this(size_t len, size_t dim, size_t limit) {
    size = len;
    count = 0;
    countMax = limit;
    nodes.length = size;
    dimension = dim;

    for(int i = 0; i < size; i++) {
      nodes[i] = new Node(dimension);
    }
  }

  double distance(int a, int b) {
    return abs(a - b);
  }

  double neighborFunction() {
    return 0.5 * size * (1.0 - (cast(double)count / countMax));
  }

  double learningFunction() {
    return 0.9 * (1.0 - (cast(double)count / countMax));
  }

  void update(double[] input) {
    int x = 0;
    double min = double.infinity;
    
    for(int i = 0; i < size; i++) {
      double d = nodes[i].distance(input);
      if(d < min) {
        min = d;
        x = i;
      }
    }

    double n = neighborFunction();
    double l = learningFunction();

    for (int i = 0; i < size; i++) {
      if(abs(i - x) <= n) {
        nodes[i].update(input, l);
      }
    }

    count++;
  }

  void print() {
    foreach(Node node; nodes) {
      foreach(double value; node.vector) {
        write(value, " \t");
      }
      writeln();
    }
  }
}

void main(string[] args)
{
  size_t countMax = 100000;
  auto som = new Som(96, 2, countMax);
  double[2] data;
  for(int i = 0; i < countMax; i++) {
    data[0] = uniform(0.0, 1.0);
    data[1] = uniform(0.0, 1.0);
    som.update(data);
  }
  som.print();
}
