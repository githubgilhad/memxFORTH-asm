: test_leds ( -- ) ( show Debug LEDs use )
  25 0 DO
    25 0 DO
      J 256 * I + ( set 2 bytes of color )
      1 LEDS! ( write to LED 1 and shine it )
    LOOP
  LOOP
  ;
