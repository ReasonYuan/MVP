package com.fq.halcyon.entity;

public class Doctor extends User {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int doctorId;

	public int getDoctorId() {
		return doctorId;
	}

	public void setDoctorId(int doctorId) {
		this.doctorId = doctorId;
	}
}
