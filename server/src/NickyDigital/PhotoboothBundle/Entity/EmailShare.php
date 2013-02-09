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
class EmailShare
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
	protected $emailFromo;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $emailTo;

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
	 * @param \NickyDigital\PhotoboothBundle\Entity\created $created
	 */
	public function setCreated($created)
	{
		$this->created = $created;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\created
	 */
	public function getCreated()
	{
		return $this->created;
	}

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\dateSent $dateSent
	 */
	public function setDateSent($dateSent)
	{
		$this->dateSent = $dateSent;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\dateSent
	 */
	public function getDateSent()
	{
		return $this->dateSent;
	}

	public function setEmailFromo($emailFromo)
	{
		$this->emailFromo = $emailFromo;
	}

	public function getEmailFromo()
	{
		return $this->emailFromo;
	}

	public function setEmailTo($emailTo)
	{
		$this->emailTo = $emailTo;
	}

	public function getEmailTo()
	{
		return $this->emailTo;
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
