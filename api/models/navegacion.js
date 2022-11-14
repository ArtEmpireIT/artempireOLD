/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('navegacion', {
		id_navegacion: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_navegacion::regclass)",
			primaryKey: true
		},
		fecha_inicio: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_inicio: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha_fin: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_fin: {
			type: DataTypes.STRING,
			allowNull: true
		},
		motivo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		}
	}, {
		tableName: 'navegacion',
		timestamps: false
	});
};
