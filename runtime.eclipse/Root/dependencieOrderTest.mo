package dependencieOrderTest
  model D
    parameter B b1(x=4);
    parameter C c1(x=5);
  end D;
 


  model A
    parameter Real x = 10;
  end A;
  
  model B extends A(x=2);
  end B;
  
  model C extends A(x=3);
  end C;
  
  
  annotation(
    Icon(coordinateSystem(initialScale = 0.5)));
end dependencieOrderTest;
