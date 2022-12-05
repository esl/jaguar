defmodule Jaguar.Vehicle.L298N do
  @moduledoc """
  L298N motor implementation.

  ## Pin layout

    - IN1 - 23 - forward
    - IN2 - 24 - backward
    - IN3 - 17
    - IN4 - 22

    - ENA - 25
    - ENB - 27
  """

  @behaviour Jaguar.Vehicle

  alias Jaguar.Vehicle

  ## Callbacks

  @impl true
  def init(vehicle) do
    %Vehicle{left: {in1, in2}, right: {in3, in4}, ena: ena, enb: enb} = vehicle

    _ =
      Enum.map([in1, in2, in3, in4], fn pin ->
        Pigpiox.GPIO.set_mode(pin, :output)
        Pigpiox.GPIO.write(pin, 0)
      end)

    _ =
      Enum.map([ena, enb], fn pin ->
        :ok = Pigpiox.GPIO.set_mode(pin, :output)
        :ok = Pigpiox.Pwm.gpio_pwm(pin, 250)
      end)

    :ok
  end

  @impl true
  def speed(vehicle) do
    %Vehicle{speed: speed, ena: ena, enb: enb} = vehicle

    :ok = Pigpiox.Pwm.gpio_pwm(ena, speed)
    :ok = Pigpiox.Pwm.gpio_pwm(enb, speed)

    :ok
  end

  @impl true
  def direction(vehicle) do
    drive(vehicle)

    :ok
  end

  ## Internal functions

  defp drive(%Vehicle{direction: :stop, left: {in1, in2}, right: {in3, in4}}) do
    _ = Enum.map([in1, in2, in3, in4], &Pigpiox.GPIO.write(&1, 0))
  end

  defp drive(%Vehicle{
         direction: :forward,
         left: {in1, in2},
         right: {in3, in4},
         ena: ena,
         enb: enb,
         speed: speed
       }) do
    :ok = Pigpiox.Pwm.gpio_pwm(ena, speed)
    :ok = Pigpiox.Pwm.gpio_pwm(enb, speed)
    _ = Enum.map([in2, in4], &Pigpiox.GPIO.write(&1, 0))
    _ = Enum.map([in1, in3], &Pigpiox.GPIO.write(&1, 1))
  end

  defp drive(%Vehicle{
         direction: :left,
         left: {in1, in2},
         right: {in3, in4},
         ena: ena,
         enb: enb,
         speed: speed
       }) do
    :ok = Pigpiox.Pwm.gpio_pwm(ena, speed - 140)
    :ok = Pigpiox.Pwm.gpio_pwm(enb, speed)
  end

  defp drive(%Vehicle{
         direction: :right,
         left: {in1, in2},
         right: {in3, in4},
         ena: ena,
         enb: enb,
         speed: speed
       }) do
    :ok = Pigpiox.Pwm.gpio_pwm(ena, speed)
    :ok = Pigpiox.Pwm.gpio_pwm(enb, speed - 140)
  end

  defp drive(%Vehicle{
         direction: :backwards,
         left: {in1, in2},
         right: {in3, in4},
         ena: ena,
         enb: enb,
         speed: speed
       }) do
    :ok = Pigpiox.Pwm.gpio_pwm(ena, speed)
    :ok = Pigpiox.Pwm.gpio_pwm(enb, speed)
    _ = Enum.map([in1, in3], &Pigpiox.GPIO.write(&1, 0))
    _ = Enum.map([in2, in4], &Pigpiox.GPIO.write(&1, 1))
  end
end
