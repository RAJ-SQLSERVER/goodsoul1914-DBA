[TOC]

# How Secure Are Encryption, Hashing, Encoding and Obfuscation?

The discipline of cryptography, necessary for a variety of security applications, is no stranger to the arms race found in all other security disciplines. While **modern cryptography aims to create mechanisms that protect information** through the application of mathematical principles and computer science, **cryptanalysis, by contrast, aims to defeat such mechanisms in order to obtain illegitimate access to the information**.

This arms race between cryptography and cryptanalysis has incentivized the creation of stronger algorithms through the ages — from [*ancient Greece and Rome*](https://en.wikipedia.org/wiki/Scytale) to our digital age and beyond. Some algorithms fall out of use due to flaws uncovered through cryptanalysis; others, simply due to advances in computation which render them ineffective when facing state-of-the-art technology.

In this post, we’ll define the security pillars of cryptography: *confidentiality*, *integrity*, and *authenticity*. We’ll then compare and contrast encryption, hashing, encoding, and obfuscation, showing which of these operations provide which of the security properties.

**Confidentiality** is about protecting information from being accessed by unauthorized parties or, in other words, is about making sure that only those who are authorized have access to restricted data. **Integrity** refers to protecting information from being altered, and **authenticity** has to do with identifying the owner of the information.

As an example, personal medical data needs to be *confidential*, meaning that only doctors or medical personnel should access it. Its *integrity* must also be protected because tampering with such data can result in a wrong diagnosis or treatment with possible health risks for the patient. Authenticity is this example means that patient data should be tied to an identified individual, and that, when a doctor modifies the data — because they authorized to do so — it’s of vital importance to know which doctor did it in a way that they can’t [*repudiate*](https://www.owasp.org/index.php/Repudiation_Attack).

We’ll now define what is encryption, hashing, encoding and obfuscation focusing mostly on identifying which of the three cryptographic properties (confidentiality, integrity, authenticity) hold true for each of them.

## What is Encryption?

Encryption is defined as the process of transforming data in such a way that guarantees confidentiality. To achieve that, encryption requires the use of a secret which, in cryptographic terms, we call a “key”.

The encryption key and any other cryptographic key should have some properties:

- The key’s value should be extremely difficult to guess in order to preserve confidentiality.
- It should be used in a single context, avoiding re-use in a different context. Key re-use carries the security risk that if its confidentiality is circumvented the impact is higher because it “unlocks” more sensitive data.

Encryption is divided into two categories: symmetric and asymmetric, where the major difference is the number of keys needed. In symmetric encryption algorithms, a single secret (key) is used to both encrypt and decrypt data. Only those who are authorized to access the data should have the single shared key in their possession. On the other hand, in asymmetric encryption algorithms, there are two keys in use: one public and one private. As their names suggest, the private key must be kept secret, whereas the public can be known to everyone. When applying encryption, the public key is used, whereas decrypting requires the private key. Anyone should be able to send us encrypted data, but only we should be able to decrypt and read it! Asymmetric encryption is usually employed to securely establish a common secret (key) between two parties communicating over an insecure channel. With this shared key, both parties now switch to symmetric encryption, which is faster and more suitable for handling large amounts of data.

### Asymmetric encryption:

![Asymmetric encryption flow diagram](https://images.ctfassets.net/23aumh6u8s0i/4K4ABiK6GnHDj6mvak2ajL/52eaa4da81e7d2d3a4e606530efee410/asymmetric-encryption-correct)

**Usage**: TLS, VPN, SSH

### Symmetric encryption:

![Symmetric encryption flow diagram](https://images.ctfassets.net/23aumh6u8s0i/3xUeddLT1IAoJYsVWvKu8f/81a63349f2b3bc0229357182586737c5/symmetric-encryption-correct)

**Usage**: file system encryption, Wi-Fi protected access (WPA), database encryption e.g. credit card details

Unfortunately, many companies use proprietary or “military-grade” cryptography for encryption. These terms usually suggest that the method to encrypt is private and is based on a “complex” algorithm. This is not how encryption should work. All encryption algorithms widely used and approved by the cryptographic community are **public** because they are based on **mathematical** algorithms, which can be solved only with the possession of a secret (the key), or with advanced computational power. [*Public algorithms are selected by competition*](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard_process), have been reviewed by the cryptographic community, and have proven their value with their wide adoption.

Recapping encryption, its primary focus is to provide confidentiality. There have been some recent encryption algorithms that also provide authenticity or integrity, but these cryptographic properties are better addressed with other techniques, as we’ll discuss below.

## What is Hashing?

Whereas encryption algorithms are reversible (with the key) and built to provide confidentiality (some newer ones also providing authenticity), **hashing algorithms are irreversible and built to provide integrity** in order to certify that a particular piece of data has not been modified.

That said, some hashing algorithms cannot guarantee data integrity as well as others, either by virtue of not having been built for security purposes or due to advancements in computation that render older algorithms obsolete.

The premise of a hashing algorithm is simple: given arbitrary input, output a specific number of bytes. This byte sequence, most of the time, will be unique to that input and will give no indication of what the input was. In other words:

1. One cannot determine the original data given only the output of a hashing algorithm.
2. Given some arbitrary data along with the output of a hashing algorithm, one can verify whether this data matches the original input data *without needing to see the original data*!

To illustrate, imagine that a strong hashing algorithm works by placing each unique input in its own bucket. When we want to check whether two inputs are the same, we can simply check if they end up in the same bucket.

### Example

It’s common for websites offering file downloads to provide the hashes of each file so that users may verify the integrity of their downloaded copies. For instance, within [*Debian’s image downloading service*](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/), you’ll find additional files, such as [*SHA256SUMS*](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS), containing hash outputs (in this case, from the SHA-256 algorithm) for each file that’s available for download. After downloading a file, you can pass it through a chosen hashing algorithm to see if the hash output that you get matches the hash output listed in the checksum file.

One way to hash a file within a terminal is to use openssl:

```bash
$ openssl sha256 ~/Downloads/debian-10.0.0-amd64-netinst.iso
SHA256(~/Downloads/debian-10.0.0-amd64-netinst.iso)=
3dbb597b7f11dbda71cda08d4c1339c1eb565e784c75409987fa2b91182d9240
```

Compare with the contents of SHA256SUMS file:

```bash
3dbb597b7f11dbda71cda08d4c1339c1eb565e784c75409987fa2b91182d9240
debian-10.0.0-amd64-netinst.iso
```

Strong hashing algorithms take the mission of generating unique output from arbitrary input to the extreme in order to guarantee data integrity. It’s nearly impossible for someone to obtain the same output given two distinct inputs into a strong hashing algorithm. This is called a collision, and when collisions become practical against a hashing algorithm, as was the case with MD5 and, most recently, with SHA-1, it’s time to move on to stronger ones. Going back to our bucket analogy, if two distinct inputs end up in the same bucket, we have a collision. This is problematic because we cannot differentiate between a collision and whether these are matching inputs. A strong hashing algorithm will almost always create a new bucket for each unique input.

![Data Integrity graphic showing unique, different hashes and same hashes - normal vs. collision](https://images.ctfassets.net/23aumh6u8s0i/6C5jFby0JGDlbZ7q8iBkkr/d0d3957803a2ca66d39903e4b500b395/example)

Source: [shattered.io](http://shattered.io/static/infographic.pdf)

You may have heard of [hashing used in the context of passwords](https://auth0.com/blog/hashing-passwords-one-way-road-to-security/). Among many uses of hashing algorithms, this is one of the most well-known. When you sign up on a web app using a password, rather than storing your actual password, which would not only be a violation of your privacy but also a big risk for the web app owner, the web app hashes the password and stores only the hash. Then, the next time you log in, the web app again hashes your password and compares this hash with the hash stored earlier. If the hashes match, the web app can be confident that you know your password even though the web app doesn’t have your actual password in storage.

#### Registration:

![Graphic of hashing during signup registration flow](https://images.ctfassets.net/23aumh6u8s0i/6RwytLlgXSWzXke7hK8lLr/126627b38351400bc78b71b1295a21bf/example-of-hashing-during-signup)

#### Login:

![Graphic of hashing during user login flow](https://images.ctfassets.net/23aumh6u8s0i/RtEkjcGaazoleKe9NizQu/de724ae66d7fa66e5715a70857bef58a/example-of-hashing-during-login)

One interesting facet of hashing, since its output is always the same length no matter the length of the input data, is that, in theory, collisions will always be within the realm of possibility, as insignificant as that possibility may be. Curiously, this is not the case for encoding, which usually outputs an amount of data proportionate to the amount of input data, and **always** unique to that input. However, as you’ll see below, encoding is **never** suitable for security-related operations.

## What is Encoding?

Encoding is defined as the process of converting data from one form to another and has nothing to do with cryptography. It guarantees none of the 3 cryptographic properties of confidentiality, integrity, and authenticity because it involves no secret and is completely reversible. Encoding methods are considered public and are **used for data handling**. For example, data transmitted over the Internet require a specific format and URL-encoding our data will allow us to transmit them over the Internet. Similarly, in an HTML context, HTML-encoding our data is needed to adhere to the required HTML character format. Another popular encoding algorithm is base64. Base64 encoding is commonly used to encode binary data that need to be stored or transferred in media which are designed to process textual data. The examples above aim to point out that encoding’s use case is only data handling and provides no protection for the encoded data.

## What is Obfuscation?

Similar to encoding, obfuscation doesn’t guarantee any security property although sometimes it’s mistakenly used as an encryption method. Obfuscation is defined as the transformation of a human-readable string to a string that is difficult for people to understand. In contrast to encryption, obfuscation includes no cryptographic key and the “secret” here is the operation itself. Remember that in encryption the method/algorithm is public and the secret is only a cryptographic key.

Although not suitable to guarantee confidentiality, obfuscation has some valid use cases. It is used heavily to prevent tampering and protect intellectual property. The source code for mobile applications is often obfuscated before being packaged, since the code lives in the users’ mobile devices from where they can extract it. Obfuscating that code helps protect intellectual property by deterring Reverse Engineering because the code is not human-friendly. In turn, this deters tampering with the code and re-distributing it for malicious uses. However, obfuscation only makes it difficult for someone to read the obfuscated code — not impossible. Many tools exist that assist in de-obfuscating application code.

Javascript file

```javascript
function hello(name) {
  console.log('Hello, ' + name);
}

hello('New user');
```

Javascript file after obfuscation

```javascript
var _0xa1cc=["\x48\x65\x6C\x6C\x6F\x2C\x20","\x6C\x6F\x67","\x4E\x65\x77\x20\x75\x73\x65\x72"];
function hello(_0x2cc8x2){console[_0xa1cc[1]](_0xa1cc[0]+ _0x2cc8x2)}hello(_0xa1cc[2])
```

## Recap with Usage Examples

Armed with the knowledge of confidentiality, integrity, and authenticity, as well as the primary purpose of encryption, hashing, encoding, and obfuscation, you can see that each mechanism serves different purposes and should be carefully chosen depending on your goals.

|                 | Encryption | Hashing | Encoding or Obfuscation |
| --------------- | ---------- | ------- | ----------------------- |
| Confidentiality | ✅          | ❌       | ❌                       |
| Integrity       | ❓          | ✅       | ❌                       |
| Authenticity    | ❓          | ❌       | ❌                       |

While encryption is meant to guarantee data confidentiality, some modern encryption algorithms employ additional strategies to also guarantee data integrity (sometimes by means of embedded hashing algorithms) as well as authenticity.

Strong hashing algorithms only guarantee data integrity and may be included in larger schemes to empower them with integrity proofs. Examples include Hash-based Message Authentication Codes (HMACs) and certain Transport Layer Security (TLS) approaches.

While the term “encode” has been used in the past to denote encryption, and may still carry that meaning outside of a technical context, in the software world, it’s only meant as a data handling mechanism that never provides any measure of security.

Lastly, obfuscation can be used to raise the bar against attacks; however, it can never *guarantee* data confidentiality. A determined adversary will eventually get around obfuscation tactics. As with encoding, never count on obfuscation as a robust security control.

### Usage examples

#### **Hashing**

- Password storage
- Data checksums
- Component in broader algorithms

#### **Encryption**

- Store sensitive data that must be retrieved (unlike passwords); e.g., credit card information.
- Protect network traffic; e.g., Wi-Fi Protected Access, Transport Layer Security, Virtual Private Networking.
- Protect data within storage media in the event of physical theft; e.g., full disk encryption.

#### **Encoding**

- Normalize data to a defined subset of characters; e.g., for easier transport over a network, or transforming binary data to a text-based format.

#### **Obfuscation**

- Raise the bar against unmotivated adversaries
- Data compression

## How Cryptography Secures Your Internet Traffic

[*Transport Layer Security*](https://www.cloudflare.com/learning/ssl/transport-layer-security-tls/) (TLS) is a protocol designed to add confidentiality as well as integrity and authenticity to network communications. Most notably, it’s the protocol that turns HTTP into HTTPS, although its usage is not limited to HTTP traffic.

> TLS is the modern version of an older protocol called Secure Sockets Layer (SSL). References to SSL today are mostly habitual because the actual SSL protocol has been deemed insecure since 2014, due to a protocol-level vulnerability nicknamed [*“POODLE”*](https://www.us-cert.gov/ncas/alerts/TA14-290A). It’s a fascinating attack, despite its name, an acronym for “Padding Oracle On Downgraded Legacy Encryption”.

To guarantee all three security properties, TLS makes use of both asymmetric and symmetric encryption in conjunction with hashing and digital signatures. Let’s see how.

**Step One: Authenticity**

When you connect to a website over HTTPS, your browser first requests that website’s [*digital certificate*](https://www.cloudflare.com/learning/ssl/what-is-an-ssl-certificate/), which is a bundle of information about the website that allows your browser to verify its authenticity. This certificate *should* be [*digitally signed*](https://en.wikipedia.org/wiki/Digital_signature) (a process that itself relies on asymmetric cryptography for authenticity and hashing for integrity) by one of the [*Certificate Authorities*](https://en.wikipedia.org/wiki/Certificate_authority) (CAs) that your browser implicitly trusts. Your browser will [*warn*](https://support.mozilla.org/en-US/kb/what-does-your-connection-is-not-secure-mean) you when the certificate is not signed *by a trusted CA*, or generally not suitable to secure your connection. In those cases, you should not visit the website unless you’re willing to give up all of the confidentiality, integrity and authenticity of your connection.

**Step Two: Confidentiality**

After authenticity has been established, the website and your browser negotiate the strongest cryptographic algorithm available to both. Using asymmetric encryption to provide confidentiality, they agree on a secret cryptographic key, and then switch to symmetric encryption using that key, which is more performant and more suitable for handling large amounts of data.

![Diffie-Hellman_Key_Exchange diagram](https://images.ctfassets.net/23aumh6u8s0i/49RKeAjGuHfML3oateA9PA/076b9e1b58a20697ce55dcd3d2cd28f6/diffie-hellman-key-exchange-diagram)

> *An illustration of how asymmetric cryptography can establish a common secret over an insecure channel. "Expensive" means prohibitively impractical or costly to perform.*

**Step Three: Integrity**

The negotiated cryptographic algorithm, called a [*cipher suite*](https://en.wikipedia.org/wiki/Cipher_suite), also makes use of hashing constructs (Hash-based Message Authentication Code, or [*HMAC*](https://en.wikipedia.org/wiki/HMAC)) or encryption modes that were already designed to provide message integrity, such as [*GCM*](https://en.wikipedia.org/wiki/Galois/Counter_Mode). This means that, in addition to cryptographically verifying that the sender of each HTTP message is authentic, the browser and website can also verify whether the message was modified or corrupted in transit!