import Foundation
import Accelerate

/// Two-section IIR cascade approximating A-weighting:
/// high-pass at 100 Hz to suppress HVAC rumble, low-pass at 8 kHz to
/// suppress hiss/very-high-frequency content. Not strict IEC 61672, but
/// the spec calls a simple cascade acceptable.
final class AWeightingFilter {
    private var biquad: vDSP.Biquad<Float>

    init(sampleRate: Double) {
        let hp = Self.highPass(cutoff: 100.0, sampleRate: sampleRate, q: 0.707)
        let lp = Self.lowPass(cutoff: 8000.0, sampleRate: sampleRate, q: 0.707)
        let coeffs = hp + lp
        self.biquad = vDSP.Biquad(
            coefficients: coeffs,
            channelCount: 1,
            sectionCount: 2,
            ofType: Float.self
        )!
    }

    func apply(to data: UnsafeMutablePointer<Float>, count: Int) {
        let buffer = UnsafeMutableBufferPointer(start: data, count: count)
        var output = [Float](repeating: 0, count: count)
        biquad.apply(input: UnsafeBufferPointer(buffer), output: &output)
        for i in 0..<count { data[i] = output[i] }
    }

    private static func highPass(cutoff: Double, sampleRate: Double, q: Double) -> [Double] {
        let omega = 2.0 * .pi * cutoff / sampleRate
        let cosO = cos(omega)
        let sinO = sin(omega)
        let alpha = sinO / (2.0 * q)

        let b0 = (1.0 + cosO) / 2.0
        let b1 = -(1.0 + cosO)
        let b2 = (1.0 + cosO) / 2.0
        let a0 = 1.0 + alpha
        let a1 = -2.0 * cosO
        let a2 = 1.0 - alpha

        return [b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0]
    }

    private static func lowPass(cutoff: Double, sampleRate: Double, q: Double) -> [Double] {
        let omega = 2.0 * .pi * cutoff / sampleRate
        let cosO = cos(omega)
        let sinO = sin(omega)
        let alpha = sinO / (2.0 * q)

        let b0 = (1.0 - cosO) / 2.0
        let b1 = 1.0 - cosO
        let b2 = (1.0 - cosO) / 2.0
        let a0 = 1.0 + alpha
        let a1 = -2.0 * cosO
        let a2 = 1.0 - alpha

        return [b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0]
    }
}
