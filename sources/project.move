module MyModule::CertificateGenerator {
    use aptos_framework::signer;
    use std::string::String;

    /// Struct representing an NFT-like certificate
    struct Certificate has key, store {
        student_name: String,       // Name of the student
        course_name: String,        // Name of the course
        issue_date: u64,            // Timestamp when issued
        educator: address,          // Address of the issuing educator
        certificate_id: u64         // Unique certificate ID
    }

    /// Struct to track an educator’s issued certificates
    struct EducatorRegistry has key, store {
        certificates_issued: u64,   // Total certificates issued by educator
        educator_name: String       // Name of the educator
    }

    /// Function for educators to register themselves in the system
    public entry fun register_educator(educator: &signer, name: String) {
        let educator_registry = EducatorRegistry {
            certificates_issued: 0,
            educator_name: name,
        };
        move_to<EducatorRegistry>(educator, educator_registry);
    }

    /// Function to issue a certificate NFT to a student.
    /// You must pass a signer for the student as well so the resource can be moved to them.
    public entry fun issue_certificate(
        educator: &signer,
        student: &signer,
        student_name: String,
        course_name: String,
        issue_date: u64
    ) acquires EducatorRegistry {
        let educator_addr = signer::address_of(educator);
        let registry = borrow_global_mut<EducatorRegistry>(educator_addr);

        // Increment certificate count and use as unique ID
        registry.certificates_issued = registry.certificates_issued + 1;
        let certificate_id = registry.certificates_issued;

        // Create the certificate NFT
        let certificate = Certificate {
            student_name,
            course_name,
            issue_date,
            educator: educator_addr,
            certificate_id,
        };

        // Move certificate to student’s account
        move_to<Certificate>(student, certificate);
    }

    /// Optional: view function to get total certificates issued by an educator
    public fun get_certificates_issued(educator_addr: address): u64 acquires EducatorRegistry {
        borrow_global<EducatorRegistry>(educator_addr).certificates_issued
    }
}
