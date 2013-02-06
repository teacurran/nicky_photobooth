<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * EmailShares
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class EmailShares
{
	/**
	 * @var integer
	 *
	 * @ORM\Column(name="id", type="integer")
	 * @ORM\Id
	 * @ORM\GeneratedValue(strategy="AUTO")
	 */
	private $id;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $email_to;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $subject;

	/**
	 * @ORM\Column(type="text")
	 */
	protected $body;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var created $created
	 *
	 * @Gedmo\Timestampable(on="create")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $created;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var dateSent $updated
	 *
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $dateSent;

	public function setBody($body)
	{
		$this->body = $body;
	}

	public function getBody()
	{
		return $this->body;
	}

	/**
	 * @param \DateTime $created
	 */
	public function setCreated($created)
	{
		$this->created = $created;
	}

	/**
	 * @return \DateTime $created
	 */
	public function getCreated()
	{
		return $this->created;
	}

	/**
	 * @param \DateTime $dateSent
	 */
	public function setDateSent($dateSent)
	{
		$this->dateSent = $dateSent;
	}

	/**
	 * @return \DateTime $dateSent
	 */
	public function getDateSent()
	{
		return $this->dateSent;
	}

	public function setEmailTo($email_to)
	{
		$this->email_to = $email_to;
	}

	public function getEmailTo()
	{
		return $this->email_to;
	}

	/**
	 * @param int $id
	 */
	public function setId($id)
	{
		$this->id = $id;
	}

	/**
	 * @return int
	 */
	public function getId()
	{
		return $this->id;
	}

	public function setSubject($subject)
	{
		$this->subject = $subject;
	}

	public function getSubject()
	{
		return $this->subject;
	}

	
}
